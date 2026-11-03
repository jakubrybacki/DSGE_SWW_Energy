function summarize_grid(run_dir)
s=load(fullfile(run_dir,'results.mat'));T=s.ranked;names=s.axes_names;
names=names(~strcmp(names,'cnu'));f=figure('Visible','off','Color','w','Position',[100 100 1100 700]);
for j=1:numel(names)
 subplot(3,3,j);v=unique(T.(names{j}));score=zeros(size(v));
 for k=1:numel(v),score(k)=min(T.NegLogLikelihood(T.(names{j})==v(k)));end
 plot(v,score,'o-','LineWidth',1.3);xlabel(names{j},'Interpreter','none');ylabel('Minimum NLL on grid');grid on;
end
sgtitle('Conditional grid at cnu=0.05: minima over other grid axes');
exportgraphics(f,fullfile(run_dir,'grid_summary.png'),'Resolution',150);close(f);
end
