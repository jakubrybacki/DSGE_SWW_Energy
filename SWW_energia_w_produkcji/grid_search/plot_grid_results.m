function plot_grid_results(run_dir)
T=readtable(fullfile(run_dir,'points.csv'));T=T(T.LikelihoodOK==1,:);
assert(~isempty(T));[best,j]=min(T.NegLogLikelihood);rho=T.crhoE(j);
S=T(abs(T.crhoE-rho)<1e-10,:);
f=figure('Visible','off','Color','w','Position',[100 100 1100 460]);
subplot(1,2,1);scatter(S.cnu,S.comegaE,70,log1p(S.NegLogLikelihood-best),'filled');
xlabel('Energy production share (nu)');ylabel('Energy consumption share (omega)');
title(sprintf('Conditional grid at rho = %.4f',rho));cb=colorbar;cb.Label.String='log(1 + increase in negative log likelihood)';grid on;
subplot(1,2,2);nu=unique(T.cnu);v=zeros(size(nu));
for i=1:numel(nu),v(i)=min(T.NegLogLikelihood(T.cnu==nu(i)))-best;end
plot(nu,v,'o-','LineWidth',1.5);xlabel('Energy production share (nu)');ylabel('Increase in negative log likelihood');
title({'Minimum over omega/rho grid','Not profile likelihood'});grid on;
exportgraphics(f,fullfile(run_dir,'grid_summary.png'),'Resolution',160);close(f);
end

