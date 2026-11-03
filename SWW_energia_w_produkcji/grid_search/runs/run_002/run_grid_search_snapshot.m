function run_grid_search(config_file)
% Isolated conditional grid: original model, calibration and ML results are read only.
base=fileparts(mfilename('fullpath')); model_root=fileparts(base);
if nargin<1,config_file=fullfile(base,'config.json');end
cfg=jsondecode(fileread(config_file));
assert(strcmp(cfg.country,'EA20'),'This reference ML fit is EA20; use a country-matched reference for other samples.');
old_dir=pwd; cleanup=onCleanup(@() cd(old_dir));
runs=fullfile(base,'runs');if ~exist(runs,'dir'),mkdir(runs);end
k=1;while exist(fullfile(runs,sprintf('run_%03d',k)),'dir'),k=k+1;end
run_dir=fullfile(runs,sprintf('run_%03d',k));mkdir(run_dir);
copy_dir=fullfile(run_dir,'model_copy');mkdir(copy_dir);
copyfile(config_file,fullfile(run_dir,'config.json'));
copyfile(mfilename('fullpath')+".m",fullfile(run_dir,'run_grid_search_snapshot.m'));
files={'sww_energia_w_produkcji.mod','sww_energia_w_produkcji_steadystate.m',...
 'Estimation_Setup','data','estymacja/wynik_ML_mode.mat','estymacja/wynik_ML_results.mat'};
for j=1:numel(files)
 src=fullfile(model_root,files{j});[~,name,ext]=fileparts(src);
 if isfolder(src),copyfile(src,fullfile(copy_dir,name));else,copyfile(src,fullfile(copy_dir,[name ext]));end
end
copyfile(fullfile(model_root,'..','Calibrations.xlsx'),fullfile(run_dir,'Calibrations_snapshot.xlsx'));
copyfile(fullfile(model_root,'..','calibration','derived_parameters.py'),fullfile(run_dir,'derived_parameters_snapshot.py'));
% Compile and initialize only in the copy, without rerunning optimization.
p=fullfile(copy_dir,'sww_energia_w_produkcji.mod');
copyfile(p,fullfile(run_dir,'original_model.mod'));t=fileread(p);
assert(contains(t,'mode_compute=5'),'Unexpected estimation specification');
t=strrep(t,'mode_compute=5','mode_compute=0');t=strrep(t,'cova_compute=1','cova_compute=0');
f=fopen(p,'w');fprintf(f,'%s',t);fclose(f);
cd(copy_dir);diary(fullfile(run_dir,'run.log'));diary_cleanup=onCleanup(@() diary('off'));
addpath(copy_dir);
dynare('sww_energia_w_produkcji.mod','noclearall','-DRUN_ESTIMATION=1');
load('wynik_ML_results.mat');ref=load('wynik_ML_mode.mat');
[dataset_,dataset_info,~,~,M_,options_,oo_,estim_params_,bayestopt_,bounds]=...
 dynare_estimation_init({},M_.fname,0,M_,options_,oo_,estim_params_,bayestopt_);
xref=ref.xparam1;param_names=string(ref.parameter_names);
% Grid domain is validated explicitly, independent of optimization box bounds.
bounds.lb=[repmat(1e-5,9,1);-1;0;0];bounds.ub=[repmat(100,9,1);1;1;1];
axes_names=fieldnames(cfg.axes);axis_values=cell(numel(axes_names),1);
for j=1:numel(axes_names)
 n=axes_names{j};assert(any(strcmp(M_.param_names,n)),'Unknown grid parameter: %s',n);
 assert(ismember(n,{'cnu','comegaE','crhoE','crpi','crhointr','cthetap','cthetaw','ch'}),...
  'Axis not supported by domain validator: %s',n);
 axis_values{j}=cfg.axes.(n)(:);
 assert(all(isfinite(axis_values{j})) && ~isempty(axis_values{j}),'Invalid axis');
 if cfg.include_ml_point
  ix=find(param_names==n);if isempty(ix),v=M_.params(strcmp(M_.param_names,n));else,v=xref(ix);end
  if n=="cnu" && abs(v)<1e-10,v=0;end
  axis_values{j}=unique([axis_values{j};v]);
 end
end
count=prod(cellfun(@numel,axis_values));assert(count<=cfg.max_points,'Grid exceeds max_points');
grid=cell(size(axis_values));[grid{:}]=ndgrid(axis_values{:});
points=zeros(count,numel(grid));for j=1:numel(grid),points(:,j)=grid{j}(:);end
T=array2table(points,'VariableNames',axes_names);T.DomainOK=false(count,1);T.SteadyOK=false(count,1);
T.BK_OK=false(count,1);T.LikelihoodOK=false(count,1);T.NegLogLikelihood=nan(count,1);
T.InfoCode=nan(count,1);T.Status=strings(count,1);T.Message=strings(count,1);
% The reference point must reproduce the saved likelihood before scanning.
reference=dsge_likelihood(xref,dataset_,dataset_info,options_,M_,estim_params_,bayestopt_,bounds,...
 oo_.dr,oo_.steady_state,oo_.exo_steady_state,oo_.exo_det_steady_state);
assert(abs(reference-ref.fval)<1e-5,'Reference likelihood mismatch');
start=tic;
for i=1:count
 mm=M_;xx=xref;
 for j=1:numel(axes_names)
  n=axes_names{j};mm.params(strcmp(mm.param_names,n))=points(i,j);
  ix=find(param_names==n);if ~isempty(ix),xx(ix)=points(i,j);end
 end
 try
  getp=@(n) mm.params(strcmp(mm.param_names,n));
  valid=getp('cnu')>=0 && getp('cnu')<1-getp('calpha') && getp('comegaE')>=0 && getp('comegaE')<1 && ...
    abs(getp('crhoE'))<1 && getp('crpi')>=0;
  for n={'crhointr','cthetap','cthetaw','ch'},v=getp(n{1});valid=valid && v>0 && v<1;end
  if ~valid,T.Status(i)="domain_rejected";continue;end
  T.DomainOK(i)=true;
  [ys,pp,check]=sww_energia_w_produkcji_steadystate(oo_.steady_state,oo_.exo_steady_state,mm,options_);
  if check~=0,T.Status(i)="steady_rejected";continue;end
  mm.params=pp;T.SteadyOK(i)=true;
  [dr,info,pp]=resol(0,mm,options_,oo_.dr,ys,oo_.exo_steady_state,oo_.exo_det_steady_state);
  T.InfoCode(i)=info(1);
  if info(1)~=0,T.Status(i)="solution_rejected";continue;end
  T.BK_OK(i)=true;mm.params=pp;
  [fval,info,ok]=dsge_likelihood(xx,dataset_,dataset_info,options_,mm,estim_params_,bayestopt_,bounds,...
    dr,ys,oo_.exo_steady_state,oo_.exo_det_steady_state);
  T.InfoCode(i)=info(1);
  if ok==1 && info(1)==0 && isfinite(fval) && isreal(fval)
   T.LikelihoodOK(i)=true;T.NegLogLikelihood(i)=fval;T.Status(i)="accepted";
  else,T.Status(i)="likelihood_rejected";end
 catch err
  T.Status(i)="exception";T.Message(i)=string(err.identifier)+": "+string(err.message);
 end
 if mod(i,cfg.checkpoint_every)==0
  writetable(T(1:i,:),fullfile(run_dir,'points.csv'));fprintf('GRID %d/%d, %.1f seconds\n',i,count,toc(start));
 end
end
writetable(T,fullfile(run_dir,'points.csv'));
ranked=sortrows(T(T.LikelihoodOK,:),'NegLogLikelihood');writetable(ranked,fullfile(run_dir,'ranking.csv'));
summary=struct('points',count,'domain_ok',sum(T.DomainOK),'steady_ok',sum(T.SteadyOK),...
 'bk_ok',sum(T.BK_OK),'likelihood_ok',sum(T.LikelihoodOK),'exceptions',sum(T.Status=="exception"),...
 'reference_negative_log_likelihood',reference,'seconds',toc(start),...
 'interpretation','Conditional grid, other parameters and shock variances fixed at ML; not profile likelihood or full identification test');
if ~isempty(ranked),summary.best=table2struct(ranked(1,:));end
fid=fopen(fullfile(run_dir,'summary.json'),'w');fprintf(fid,'%s',jsonencode(summary,PrettyPrint=true));fclose(fid);
save(fullfile(run_dir,'results.mat'),'T','ranked','summary','cfg','axis_values','axes_names','xref');
fid=fopen(fullfile(base,'latest_run.txt'),'w');fprintf(fid,'%s',run_dir);fclose(fid);
disp(summary);fprintf('RESULTS: %s\n',run_dir);
end
