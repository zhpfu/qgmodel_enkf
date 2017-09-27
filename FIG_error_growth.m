addpath util
workdir='/glade/scratch/mying/qgmodel_enkf';
cmap1=colormap(jet(5));
smth=1.03;

expname='lowres';
factor=1;
n1=1; nt=30;
lv=1;

close all
	set(gca,'fontsize',20)
  p=get(gca,'position'); p(2)=p(2)+0.1; p(3)=p(3)-0.2; p(4)=p(4)-0.2; set(gca,'position',p);

	load([workdir '/errspec/' expname '/noda_spinup_temp'])
  cmap=colormap(jet(nt));
  for n=n1:2:nt
  	plotspec(w*factor,mean(sprd1(:,lv,n)/factor,3),smth,cmap(n,:)*0.8,'-',1); hold on
  end

	load([workdir '/errspec/' expname '/ref_temp'])
	plotspec(w*factor,mean(ref(:,lv,n1:nt)/factor,3),smth,'k','-',2); hold on
	%plotspec(w1*factor,mean(oberr(:,n1:nt)/factor,2),smth,[.5 .5 .5],'-',2)

	plotspec([3:15],(3e1)*[3:15].^(-5/3),1,[.7 .7 .7],'-',2);
	text(7,2,'-5/3','color',[.7 .7 .7],'fontsize',20);
	plotspec([15:60],(1e3)*[15:60].^(-3),1,[.7 .7 .7],'-',2);
	text(30,0.06,'-3','color',[.7 .7 .7],'fontsize',20);

	axis([1 100 1e-4 1e1])
	xlabel('wavenumber','fontsize',22)
  set(gca,'YTick',10.^[-10:10]);
  grid on; 

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
