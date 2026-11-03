function check_grid_hessian
base=fileparts(mfilename('fullpath')); source=fullfile(base,'runs','run_004');
outdir=fullfile(source,'hessian');if ~exist(outdir,'dir'),mkdir(outdir);end
work=fullfile(outdir,'model_copy');if ~exist(work,'dir'),mkdir(work);end
for name={'sww_energia_w_produkcji.mod','sww_energia_w_produkcji_steadystate.m','Estimation_Setup','data','wynik_ML_results.mat','wynik_ML_mode.mat'}
 copyfile(fullfile(source,'model_copy',name{1}),fullfile(work,name{1}));
end
old=pwd;cleanup=onCleanup(@()cd(old));cd(work);addpath(work);
dynare('sww_energia_w_produkcji.mod','noclearall','-DRUN_ESTIMATION=1');
load('wynik_ML_results.mat');ref=load('wynik_ML_mode.mat');fit=load(fullfile(source,'reference_profile.mat'));
[dataset_,dataset_info,~,~,M_,options_,oo_,estim_params_,bayestopt_,bounds]=dynare_estimation_init({},M_.fname,0,M_,options_,oo_,estim_params_,bayestopt_);
r=load(fullfile(source,'results.mat'));best=r.ranked(1,:);x=fit.x;names=string(ref.parameter_names(:));
core=["crpi";"crhointr";"cthetap";"cthetaw";"ch"];
for n=string(r.axes_names(:))'
 M_.params(strcmp(M_.param_names,n))=best.(n);ix=find(names==n);if ~isempty(ix),x(ix)=best.(n);end
end
free=find(names~="cnu");cnames=[names(free);core];z=[x(free);zeros(numel(core),1)];
for j=1:numel(core),z(numel(free)+j)=best.(core(j));end
bounds.lb=[repmat(1e-5,9,1);.001;0;.001];bounds.ub=[repmat(100,9,1);.995;.2;.35];
fun=@(v) evaluate(v,x,free,core,dataset_,dataset_info,options_,M_,estim_params_,bayestopt_,bounds,oo_);
f0=fun(z);assert(abs(f0-best.NegLogLikelihood)<1e-6,'Grid likelihood mismatch');
N=numel(z);HH=cell(2,1);GG=cell(2,1);
for pass=1:2
 h=max(abs(z),.1)*(1e-3/10^(pass-1));H=zeros(N);g=zeros(N,1);
 for a=1:N
  pp=z;mm=z;pp(a)=pp(a)+h(a);mm(a)=mm(a)-h(a);fp=fun(pp);fm=fun(mm);
  H(a,a)=(fp-2*f0+fm)/h(a)^2;g(a)=(fp-fm)/(2*h(a));
  for b=1:a-1
   pp=z;pm=z;mp=z;mm=z;
   pp(a)=pp(a)+h(a);pp(b)=pp(b)+h(b);pm(a)=pm(a)+h(a);pm(b)=pm(b)-h(b);
   mp(a)=mp(a)-h(a);mp(b)=mp(b)+h(b);mm(a)=mm(a)-h(a);mm(b)=mm(b)-h(b);
   H(a,b)=(fun(pp)-fun(pm)-fun(mp)+fun(mm))/(4*h(a)*h(b));H(b,a)=H(a,b);
  end
 end
 HH{pass}=H;GG{pass}=g;fprintf('HESSIAN pass %d complete\n',pass);
end
reports=struct;
for dim=[11 16]
 key=sprintf('parameters_%d',dim);A=HH{2}(1:dim,1:dim);B=HH{1}(1:dim,1:dim);ev=eig(A);ev1=eig(B);
 reports.(key)=struct('min_eigenvalue',min(ev),'max_eigenvalue',max(ev),'negative_eigenvalues',sum(ev<0),'coarse_min_eigenvalue',min(ev1),'coarse_negative_eigenvalues',sum(ev1<0),'max_abs_gradient',max(abs(GG{2}(1:dim))),'relative_step_difference',norm(A-B,'fro')/norm(A,'fro'),'eigenvalues',ev);
end
reports.negative_log_likelihood=f0;reports.fixed_cnu=.05;
T=table(cnames,z,GG{2},'VariableNames',{'Parameter','Value','GradientNegativeLogLikelihood'});writetable(T,fullfile(outdir,'gradient.csv'));
save(fullfile(outdir,'hessian.mat'),'HH','GG','z','cnames','reports');
fid=fopen(fullfile(outdir,'summary.json'),'w');fprintf(fid,'%s',jsonencode(reports,PrettyPrint=true));fclose(fid);disp(reports);disp(T);
end
function f=evaluate(z,x,free,core,data,di,opts,M,ep,bo,bounds,oo)
x(free)=z(1:numel(free));
for j=1:numel(core),M.params(strcmp(M.param_names,core(j)))=z(numel(free)+j);end
[f,info,ok]=dsge_likelihood(x,data,di,opts,M,ep,bo,bounds,oo.dr,oo.steady_state,oo.exo_steady_state,oo.exo_det_steady_state);
assert(ok==1 && info(1)==0 && isfinite(f) && isreal(f),'Invalid likelihood at Hessian evaluation');
end
