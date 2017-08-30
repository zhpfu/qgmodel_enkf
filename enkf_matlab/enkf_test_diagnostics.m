%clear all
%load enkf_test_obthin

%close all
%smth=1.01;
%cmap=colormap(jet(5));

%set(gca,'fontsize',14)
%for l=1:5
%%loglog(w,smooth_spec(w,squeeze(err2(:,l,2)),smth),'color',cmap((l),:),'linewidth',1); hold on
%loglog(w,smooth_spec(w,squeeze(err22(:,l)),smth),'color',cmap((l),:),'linewidth',1); hold on
%end
%loglog(w,smooth_spec(w,ref,smth),'color',[.7 .7 .7],'linewidth',2); hold on 
%%loglog(w1,smooth_spec(w1,oberr,smth),'color',[.7 .7 .7],'linewidth',1);
%loglog(w,smooth_spec(w,err1,smth),'k','linewidth',2);
%axis([1 128 1e-7 1])
%xlabel('wavenumber','fontsize',20);

%saveas(gca,'~/html/1','pdf')

%clear all
load enkf_test_localize

close all
smth=1.05;
cmap=colormap(jet(length(lc)));

set(gca,'fontsize',14)
for l=1:size(err2,2)
	loglog(w,smooth_spec(w,err2(:,l),smth),'color',cmap((l),:),'linewidth',1); hold on
  %loglog(w,smooth_spec(w,err2(:,l),smth),'b','linewidth',2); hold on
	%loglog(w,smooth_spec(w,sprd2(:,l),smth),'c','linewidth',2); hold on
end
%loglog(w,smooth_spec(w,ref,smth),'color',[.7 .7 .7],'linewidth',2); hold on 
%loglog(w1,smooth_spec(w1,oberr,smth),'color',[.7 .7 .7],'linewidth',2);
loglog(w,smooth_spec(w,err1,smth),'k','linewidth',2);
%loglog(w,smooth_spec(w,sprd1,smth),'color',[.3 .7 .3],'linewidth',2);
axis([1 128 1e-7 1])
xlabel('wavenumber','fontsize',20);

saveas(gca,'~/html/1','pdf')
