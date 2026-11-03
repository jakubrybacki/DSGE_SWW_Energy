"""Generate exactly three Dynare input modules per model from Calibrations.xlsx.
Usage: python calibration/generate_mod_inputs.py --country EA20
Requires Python >=3.10 and openpyxl. No Excel automation or cached formula values.
"""
from __future__ import annotations
import argparse, ast, csv, hashlib, json, math, operator, re, sys
from pathlib import Path
import openpyxl
from derived_parameters import IDENTITIES
ROOT=Path(__file__).resolve().parents[1]
SPEC=json.loads((Path(__file__).with_name('model_specifications.json')).read_text(encoding='utf-8'))
BIN={ast.Add:operator.add,ast.Sub:operator.sub,ast.Mult:operator.mul,ast.Div:operator.truediv,ast.Pow:operator.pow}
CMP={ast.Eq:operator.eq,ast.NotEq:operator.ne,ast.Lt:operator.lt,ast.LtE:operator.le,ast.Gt:operator.gt,ast.GtE:operator.ge}
def parse_expression(text):
    tree=ast.parse(text,mode='eval').body
    allowed=(ast.Expression,ast.BinOp,ast.UnaryOp,ast.IfExp,ast.Compare,ast.Name,ast.Load,ast.Constant,ast.UAdd,ast.USub,*BIN,*CMP)
    for node in ast.walk(tree):
        if not isinstance(node,allowed):raise ValueError(f'Unsupported expression element: {type(node).__name__}')
        if isinstance(node,ast.Constant) and (type(node.value) not in (int,float) or not math.isfinite(node.value)):
            raise ValueError('Expression constants must be finite numbers')
    return tree

def evaluate(node,env):
    if isinstance(node,ast.Constant):return node.value
    if isinstance(node,ast.Name):return env[node.id]
    if isinstance(node,ast.BinOp):return BIN[type(node.op)](evaluate(node.left,env),evaluate(node.right,env))
    if isinstance(node,ast.UnaryOp):return (-1 if isinstance(node.op,ast.USub) else 1)*evaluate(node.operand,env)
    if isinstance(node,ast.IfExp):return evaluate(node.body if evaluate(node.test,env) else node.orelse,env)
    if isinstance(node,ast.Compare):
        vals=[evaluate(n,env) for n in [node.left,*node.comparators]]
        return all(CMP[type(op)](vals[i],vals[i+1]) for i,op in enumerate(node.ops))
    raise ValueError('Unsupported expression')

def matlab(node):
    if isinstance(node,ast.Constant):return format(node.value,'.15g')
    if isinstance(node,ast.Name):return node.id
    if isinstance(node,ast.BinOp):
        symbols={ast.Add:'+',ast.Sub:'-',ast.Mult:'*',ast.Div:'/',ast.Pow:'^'}
        return '('+matlab(node.left)+symbols[type(node.op)]+matlab(node.right)+')'
    if isinstance(node,ast.UnaryOp):return ('-' if isinstance(node.op,ast.USub) else '+')+'('+matlab(node.operand)+')'
    if isinstance(node,ast.Compare):
        symbols={ast.Eq:'==',ast.NotEq:'~=',ast.Lt:'<',ast.LtE:'<=',ast.Gt:'>',ast.GtE:'>='}
        vals=[node.left,*node.comparators]
        return ' && '.join('('+matlab(vals[i])+symbols[type(op)]+matlab(vals[i+1])+')' for i,op in enumerate(node.ops))
    raise ValueError('Conditional expressions must be top-level')

def assignment(name,node):
    if isinstance(node,ast.IfExp):
        return ['if '+matlab(node.test),*assignment(name,node.body),'else',*assignment(name,node.orelse),'end;']
    return [name+' = '+matlab(node)+';']

def read_rows(path,country):
    book=openpyxl.load_workbook(path,read_only=True,data_only=False)
    try:
        sheet=book['Parameters']; it=iter(sheet.values); headers=list(next(it))
        if len(headers)!=len(set(headers)):raise ValueError('Duplicate workbook columns')
        for h in ['Variable','Description','Model',country]:
            if h not in headers:raise ValueError('Missing column: '+h)
        rows=[];seen=set()
        for number,values in enumerate(it,2):
            row=dict(zip(headers,values));name=row['Variable']
            if name is None and all(v is None for v in values):continue
            if not isinstance(name,str) or not re.fullmatch(r'[A-Za-z]\w*',name):raise ValueError(f'Invalid Variable at row {number}')
            scope=row['Model']
            if scope not in ('both','classic','energy'):raise ValueError(f'Invalid Model at row {number}')
            if (scope,name) in seen:raise ValueError(f'Duplicate parameter {scope}/{name}')
            seen.add((scope,name))
            if not row['Description']:raise ValueError('Missing description: '+name)
            value=row[country]
            if type(value) not in (int,float) or not math.isfinite(value):raise ValueError(f'{country}: missing or nonnumeric {name} (row {number})')
            node=ast.Constant(value=value)
            row['node']=node;rows.append(row)
        return rows
    finally:book.close()

def resolve(rows,model):
    applicable=[r for r in rows if r['Model'] in ('both',model)]
    for scope in ('both',model):
        for name,expression in IDENTITIES[scope].items():
            applicable.append({'Variable':name,'Model':scope,'Description':SPEC['descriptions'][name],
                               'node':parse_expression(expression)})
    names=[r['Variable'] for r in applicable]
    if len(names)!=len(set(names)):raise ValueError('Overlapping both/model rows')
    expected=set(SPEC['models'][model]['declarations']['parameters'])
    if set(names)!=expected:raise ValueError(f'{model}: parameter mismatch {set(names)^expected}')
    pending=applicable[:];ordered=[];env={}
    while pending:
        progressed=False
        for row in pending[:]:
            deps={n.id for n in ast.walk(row['node']) if isinstance(n,ast.Name)}
            if not deps<=expected:raise ValueError(f'Unknown dependencies: {deps-expected}')
            if not deps<=env.keys():continue
            value=evaluate(row['node'],env)
            if type(value) not in (int,float) or not math.isfinite(value):raise ValueError(f'Nonfinite or complex {row["Variable"]}')
            env[row['Variable']]=value;ordered.append(row);pending.remove(row);progressed=True
        if not progressed:raise ValueError('Cyclic dependencies: '+','.join(r['Variable'] for r in pending))
    # Economic domains required by these calibrated models, not estimation bounds.
    for n in ['c_h','c_delta','c_alpha','c_theta_p','c_theta_w','c_theta_e','c_rho_intr','c_v','c_psi']:
        if not 0<env[n]<1:raise ValueError(n+' must lie strictly between 0 and 1')
    for n in ['c_gamma_p','c_gamma_w']:
        if not 0<=env[n]<=1:raise ValueError(n+' must lie between 0 and 1')
    for n,v in env.items():
        if n.startswith('c_rho') and n not in ('c_rho_intr','c_rho_g_a') and not abs(v)<1:raise ValueError(n+' must be stationary')
        if (n.startswith('sigma_') or n in ('c_sigma_e','c_sigma_f')) and v<0:raise ValueError('Negative shock standard deviation: '+n)
    for n in ['c_c_y','c_i_y','c_k_y','c_w','c_r_k','c_beta','c_tau','c_omega','c_phi']:
        if env[n]<=0:raise ValueError(n+' must be positive')
    if env['c_psi_p']<=1 or env['c_psi_w']<=1:raise ValueError('Markups must exceed 1')
    if model=='energy':
        if not 0<=env['c_nu']<1-env['c_alpha'] or not 0<=env['c_omega_e']<1:raise ValueError('Invalid energy shares')
    if model=='energy' and not (0 <= env['c_omega_f'] < 1-env['c_omega_e']):raise ValueError('Invalid food consumption share')
    return ordered,env

def measurement_text(model,country):
    spec=SPEC['models'][model]
    lines=['// Common measurement equations for simulation and estimation.',
           '// robs is annual percent in the data. robs/4 is quarterly percent, like crbar and r.',
           '// Intercepts retain the workbook calibration; sample means below are diagnostics.']
    data=ROOT/spec['folder']/'data'/country/'observables.csv'
    if data.exists():
        with data.open(encoding='utf-8-sig',newline='') as f: records=list(csv.DictReader(f))
        if not records:raise ValueError('Empty observations file: '+str(data))
        lines.append('// Data sample: '+records[0]['quarter']+' -- '+records[-1]['quarter'])
        for name in SPEC['observables'][:8 if model=='classic' else 10]:
            values=[float(row[name] if name in row else row[{v: k for k, v in SPEC['models'][model]['declarations']['var']} if False else ({'dy_obs':'dyobs','dc_obs':'dcobs','di_obs':'diobs','pi_obs':'piobs','dw_obs':'dwobs','de_obs':'deobs','u_obs':'uobs','r_obs':'robs','p_e_obs':'pEobs','p_f_obs':'pFobs'}.get(name, name))]) for row in records]
            if not all(math.isfinite(v) for v in values):raise ValueError('Nonfinite observations: '+name)
            lines.append(f'// Sample mean {name}: {sum(values)/len(values):.15g}')
        lines.append('// Source SHA256: '+hashlib.sha256(data.read_bytes()).hexdigest())
    else:lines.append('// No local observations for this country; calibrated measurement equations retained.')
    for eq in spec['measurement']:
        name=re.match(r'\w+',eq).group()
        lines += ["[name = '"+SPEC['descriptions'][name]+"']",eq]
    return '\n'.join(lines)+'\n'


def steady_state_text(spec,ordered):
    stem=spec['stem']
    lines=[f'function [ys,params,check] = {stem}_steadystate(ys,exo,M_,options_)',
        '% Generated from derived_parameters.py; recomputed for every parameter draw.',
        'params=M_.params; check=0;']
    for n in spec['declarations']['parameters']:
        lines.append(n+" = params(strcmp(M_.param_names,'"+n+"'));")
    derived=set().union(*(set(x) for x in IDENTITIES.values()))
    for row in ordered:
        if row['Variable'] in derived:lines+=assignment(row['Variable'],row['node'])
    for row in ordered:
        n=row['Variable']
        if n in derived:lines.append("params(strcmp(M_.param_names,'"+n+"'))="+n+';')
    lines+=['if ~isreal(params) || any(~isfinite(params)) || c_c_y<=0 || c_r_k<=0 || c_alpha_n<=0 || c_omega_f<0 || c_omega_e<0 || c_omega_e+c_omega_f>=1',
            'check=1; return; end', 'ys(:)=0;']
    means={'dy_obs':'c_tau_bar+c_e_bar','dc_obs':'c_tau_bar+c_e_bar','di_obs':'c_tau_bar+c_e_bar',
           'pi_obs':'c_pi_bar','dw_obs':'c_tau_bar+c_pi_bar','de_obs':'c_e_bar','u_obs':'c_u_bar',
           'r_obs':'4*c_r_bar','pi_d_obs':'c_pi_bar','pi_e_obs':'c_pi_bar','pi_f_obs':'c_pi_bar'}
    for n,expression in means.items():
        lines.append("ys(strcmp(M_.endo_names,'"+n+"'))="+expression+';')
    lines+=['end','']
    return '\n'.join(lines)

def generate(workbook,country,check=False):
    rows=read_rows(workbook,country);outputs={};report={}
    digest=hashlib.sha256(workbook.read_bytes()).hexdigest()
    for model,spec in SPEC['models'].items():
        ordered,env=resolve(rows,model)
        head=['// Generated by calibration/generate_mod_inputs.py; edit Calibrations.xlsx.',
              '// Identities: calibration/derived_parameters.py',
              '// Country: '+country,'// Workbook SHA256: '+digest,
              '// Identities SHA256: '+hashlib.sha256(Path(__file__).with_name('derived_parameters.py').read_bytes()).hexdigest()]
        lines=head[:]
        for row in ordered:
            n=row['Variable'];desc=str(row['Description']).replace('\n',' ')
            lines.append('// '+desc)
            macro={'c_nu':'ENERGY_PRODUCTION_SHARE','c_omega_e':'ENERGY_CONSUMPTION_SHARE','c_omega_f':'FOOD_CONSUMPTION_SHARE'}.get(n)
            if macro:
                # Validation override only; the default still comes from the workbook.
                lines += ['@#ifndef '+macro,'@#define '+macro+' = '+format(env[n],'.15g'),'@#endif',n+' = @{'+macro+'};']
            else:lines+=assignment(n,row['node'])
        directory=ROOT/spec['folder']/'Estimation_Setup'
        outputs[directory/(country+'_calibration.mod')]='\n'.join(lines)+'\n'
        outputs[directory/(country+'_measurement.mod')]=measurement_text(model,country)
        shocks=head+['shocks;']
        for row in spec['shocks']:shocks += ['var '+row['Variable']+'; stderr '+row['Parameter']+';']
        shocks+=['end;']
        outputs[directory/(country+'_shocks.mod')]='\n'.join(shocks)+'\n'
        report[model]=env
        if model=='energy':
            outputs[ROOT/spec['folder']/(spec['stem']+'_steadystate.m')]=steady_state_text(spec,ordered)
    if not check:
        # Prepare every validated file before replacing any active module.
        staged=[]
        for path,content in outputs.items():
            path.parent.mkdir(parents=True,exist_ok=True)
            tmp=path.with_suffix('.mod.tmp');tmp.write_text(content,encoding='utf-8');staged.append((tmp,path))
        for tmp,path in staged:tmp.replace(path)
        (ROOT/'calibration'/(country+'_resolved.json')).write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(('Checked' if check else 'Generated')+f' {len(outputs)} files for {country}')
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--country',default='EA20');p.add_argument('--workbook',type=Path,default=ROOT/'Calibrations.xlsx')
    p.add_argument('--check',action='store_true',help='Validate workbook without writing files')
    a=p.parse_args();country=a.country.upper()
    if country=='EA':country='EA20'
    if not re.fullmatch(r'[A-Z][A-Z0-9_]*',country):p.error('Invalid country code')
    try:generate(a.workbook.resolve(),country,a.check)
    except (ValueError,KeyError,ZeroDivisionError,OverflowError,FileNotFoundError,SyntaxError) as exc:
        p.exit(1,'ERROR: '+str(exc)+'\n')
if __name__=='__main__':main()
