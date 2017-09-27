workdir='/glade/scratch/mying/qgmodel_enkf/';
cmap1=colormap(jet(5));
krange=[0 5 20 64];

expname='TN64';
expname0='TN64';
varname='temp';

close all
nt=50;
ts=[1 250];
lv=1;

nl=[8 16 32 64];
cmap1=0.8*colormap(jet(5)); cmap1(3,:)=[];

for nn=1:2
for kk=1:2
  subplot(2,2,2*(kk-1)+nn)
  set(gca,'fontsize',12)
  p=get(gca,'pos'); p(3)=p(3)+0.04; set(gca,'pos',p);

  t(1:2:2*nt)=ts(nn):ts(nn)+nt-1; t(2:2:2*nt)=ts(nn):ts(nn)+nt-1;
  for l=length(nl):-1:1
    load([workdir '/errspec/' expname '/sl' num2str(nl(l)) '_' varname])
    errpwr(1:2:2*nt)=squeeze(mean(err1(krange(kk)+1:krange(kk+1),lv,ts(nn):ts(nn)+nt-1),1));
    errpwr(2:2:2*nt)=squeeze(mean(err2(krange(kk)+1:krange(kk+1),lv,ts(nn):ts(nn)+nt-1),1));
    semilogy(t,errpwr,'color',cmap1(l,:),'linewidth',1.5); hold on
  end

	load([workdir '/errspec/' expname0 '/noda_' varname])
	t1=ts(nn):ts(nn)+nt-1;
	errpwr1(1:nt)=squeeze(mean(err1(krange(kk)+1:krange(kk+1),lv,ts(nn):ts(nn)+nt-1),1));
	semilogy(t1,errpwr1,'color',[0 0 0],'linewidth',1.5); hold on

  if(kk<3)
  	load([workdir '/errspec/' expname0 '/oberr_' varname])
    obserr(1:nt)=squeeze(mean(oberr(krange(kk)+1:krange(kk+1),ts(nn):ts(nn)+nt-1),1));
    semilogy(t1,obserr,'color',[.7 .7 .7],'linewidth',1.5)
  end

  %axis([ts-1 ts+nt 1e-3 1e0])
  if(nn==2); set(gca,'YTickLabel',[]); end
	%xlabel('cycle','fontsize',12)
	%if(kk==1); ylabel('error power','fontsize',12); end
	%if(nn==1 && kk==2)
    %h=legend('ROI=64','ROI=32','ROI=16','ROI=8','NoDA','ObsError');
    %set(h,'location','southoutside','orientation','horizontal','fontsize',10,'position',[0.8 0.3 0.1 0.1])
  %end
  
end
end

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/')
