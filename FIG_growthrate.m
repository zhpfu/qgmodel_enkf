clear all

addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/qgmodel_enkf/model/qgbci


wk=0:64; wl=0:64;
w=0:63;

getparams('/glade/scratch/mying/qgmodel_enkf/TN64/truth');
wi=qggrz(z,rho,ubar,vbar,F,beta,0,wk,wl);
[k l]=ndgrid(wk,wl);
kk=sqrt(k.^2+l.^2);
for n=1:length(w)-1
  ind=(kk>=w(n) & kk<w(n+1));
  gr(n)=sum(wi(ind))/sum(ind(:));
end
gr(length(w))=0;
semilogx(w,gr,'k','linewidth',2); hold on

getparams('/glade/scratch/mying/qgmodel_enkf/lowres3/truth');
wi=qggrz(z,rho,ubar,vbar,F,beta,0,wk,wl);
[k l]=ndgrid(wk,wl);
kk=sqrt(k.^2+l.^2);
for n=1:length(w)-1
  ind=(kk>=w(n) & kk<w(n+1));
  gr(n)=sum(wi(ind))/sum(ind(:));
end
gr(length(w))=0;
semilogx(w,gr,'r','linewidth',2); hold on

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')

close all
