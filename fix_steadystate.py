import re

def fix():
    with open('SWW_energia_w_produkcji/sww_energia_w_produkcji_steadystate.m', 'r', encoding='utf-8') as f:
        code = f.read()

    new_code = re.sub(r"params\(strcmp\(M_\.param_names,\s*'([^']+)'\)\)\s*=\s*([^;]+);",
                      r"params = set_par(params, M_.param_names, '\1', \2);", code)
    new_code = re.sub(r"params\(strcmp\(M_\.param_names,\s*'([^']+)'\)\)",
                      r"get_par(params, M_.param_names, '\1')", new_code)

    helper = """
function val = get_par(params, param_names, name)
idx = find(strcmp(param_names, name) | strcmp(param_names, strrep(name, '_', '')) | strcmpi(param_names, strrep(name, '_', '')));
if ~isempty(idx)
    val = params(idx(1));
else
    val = 0;
end
end

function params = set_par(params, param_names, name, val)
idx = find(strcmp(param_names, name) | strcmp(param_names, strrep(name, '_', '')) | strcmpi(param_names, strrep(name, '_', '')));
if ~isempty(idx)
    params(idx(1)) = val;
end
end
"""
    new_code = new_code + helper
    with open('diagnostyka/runs/ceny_roczne_phi15/model_roczne/sww_energia_w_produkcji_steadystate.m', 'w', encoding='utf-8') as f:
        f.write(new_code)
    print("Steadystate updated successfully!")

if __name__ == '__main__':
    fix()
