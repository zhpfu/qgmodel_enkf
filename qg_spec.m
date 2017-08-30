nt=100;
psik=read_field('qg/truth/psi',nkx,nky,nz,5000+(1:nt));
[uk vk]=psi2uv(psik);
u=spec2grid(uk); v=spec2grid(vk);
[w p]=KEspec(u,v);
close
cmap=colormap(jet(nt));
for i=1:nt
  loglog(w,smooth_spec(w,p(:,2,i),1.05),'-','color',cmap(i,:)); hold on
end
loglog(w,10*w.^(-5/3),'k')
loglog(w,10*w.^(-3),'color',[.7 .7 .7])
axis([1 63 1e-5 1e2])
saveas(gca,'~/html/1','pdf')

