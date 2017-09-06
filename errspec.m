addpath util
workdir='/glade/scratch/mying/qgmodel_enkf';
smth=1.03;

expname='ctrl';
nl=[8 16 32 64]; 
cmap1=0.8*colormap(jet(length(nl)));

factor=1;

close all
%for n=1:28
n1=3; nt=3;
	set(gca,'fontsize',18)

	load([workdir '/errspec/' expname '/noda'])
  %cmap=colormap(jet(nt));
  %for n=n1:10:nt
    %plotspec(w*factor,mean(sprd1(:,n)/factor,2),smth,cmap(n,:)*0.8,'-',1); hold on
  %end
  plotspec(w*factor,mean(err1(:,n1:nt)/factor,2),smth,[.7 .7 .7],'-',2); hold on
	plotspec(w*factor,mean(ref(:,n1:nt)/factor,2),smth,'k','-',2); hold on
	plotspec(w1*factor,mean(oberr(:,n1:nt)/factor,2),smth,[.7 .7 .7],'-',2)

	for l=1:length(nl)
		load([workdir '/errspec/' expname '/new/sl' num2str(nl(l))])
		plotspec(w*factor,mean(err2(:,n1:nt)/factor,2),smth,cmap1(l,:),'-',2); hold on
		%plotspec(w*factor,mean(sprd2(:,n1:nt)/factor,2),smth,cmap1(l,:),'.',2); hold on
	end

	%load([workdir '/errspec/' expname '/test1'])
	%plotspec(w,mean(err1(:,n),2),smth,'k','-',1); hold on
	%plotspec(w,mean(sprd1(:,n),2),smth,'k','.',1); hold on

	axis([1 100 1e-4 1e1])
	xlabel('wavenumber','fontsize',22)
	ylabel('KE','fontsize',22);
%end

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
