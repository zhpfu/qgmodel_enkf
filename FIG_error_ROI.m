clear all
close all
addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/qgmodel_enkf/enkf_matlab
workdir='/glade/scratch/mying/qgmodel_enkf';

krange=[0 5 21];

varname='temp'; vartype='T';
%varname='u'; vartype='uv';
lv=1;
n1=50; nt=300;

y1=[0.0 0.0 0.5];
y2=[1.5 3.0 1.5];
yloc=[-0.1 -0.2 0.44];
expname={'N16','N32','N64','N256','N1024'};
ltext={'N=16','N=32','N=64','N=256','N=1024'};

%y1=[0.0 0.0 0.0];
%y2=[1.5 3.5 1.6];
%yloc=[-0.1 -0.23 -0.1];
%expname={'N64_thin9','N64_obserr2','N64','N64_obserr1','N64_thin1'};
%vartype=['randloc_' vartype];
%ltext={'ObsSparse','ObsErrorX3','CNTL','ObsError/3','ObsDense'};

color={[1 0 0],[1 .5 0],[0 0 0],[.3 .7 .3],[0 .5 .9]};

l=[8 12 16 20 24 32 40 48 64 256];

for k=1:length(krange)
for c=1:length(expname)
  for i=1:length(l)
    infile=[workdir '/errspec/' vartype cell2mat(expname(c)) '/sl' num2str(l(i)) '_' varname '.mat'];
    if(exist(infile,'file')==2)
      load(infile);
      p=squeeze(mean(err2(:,lv,n1:min(nt,end)),3));
      p=smooth_spec(w,p,1.03);
      r=scale_response(w,krange,k);
			err(k,c,i)=sqrt(sum(p.*r));
    else  
      err(k,c,i)=NaN;
    end
  end
end
end
for k=1:length(krange)
  subplot(3,1,k)
  set(gca,'fontsize',10);
  p=get(gca,'position'); p(3)=p(3)-0.5; p(4)=p(4)+0.04; set(gca,'position',p);
  for c=1:length(expname)
    plot(l,squeeze(err(k,c,:)),'o-','color',cell2mat(color(c)),'markersize',3,'markerfacecolor','w'); hold on
  end
  for c=1:length(expname)
    plot(l,squeeze(err(k,c,:)),'o','markersize',4,'markerfacecolor','w','markeredgecolor','w'); 
  end
  for c=1:length(expname)
				plot(l,squeeze(err(k,c,:)),'o','color',cell2mat(color(c)),'markersize',3);
    plot(l(err(k,c,:)==nanmin(err(k,c,:))),nanmin(err(k,c,:)),'o','color',cell2mat(color(c)),'markersize',3,'markerfacecolor',cell2mat(color(c)));
  end
  text(77,yloc(k),'\infty','color','k','fontsize',14);

	axis([0 80 y1(k) y2(k)])
  set(gca,'XTick',[8 16 32 64]);
  grid on
	if(k==3); xlabel('ROI','fontsize',14); end
	%if(k==1); h=legend(ltext); set(h,'fontsize',8,'location','northwest'); end
end

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')

close all
