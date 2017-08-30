addpath /wall/s0/yxy159/qgmodel_enkf/util
addpath /wall/s0/yxy159/graphics
workdir='/wall/s0/yxy159/qgmodel_enkf/sqg';

close all
colormap(colormap_ncl('/wall/s0/yxy159/graphics/colormap/BlWhRe.rgb',41))

getparams([workdir '/truth']);

n=10;
nid=sprintf('%5.5i',n);
nens=2000;

for m=1:nens
	psik=read_field([workdir '/ensemble_big/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',n)],nkx,nky,nz,1);
	psi(:,:,:,m)=spec2grid(psik);
	%temp(:,:,:,m)=spec2grid(psi2temp(psik));
end
psi_mean=mean(psi(:,:,:,1:nens),4);
%temp_mean=mean(temp(:,:,:,1:nens),4);

[x,y,z]=ndgrid(1:nx,1:ny,1:nz);

c=0;
for i=5:10:250
for j=5:10:250
c=c+1;

dist=sqrt((min(abs(x-i),abs(nx-x+i))).^2+(min(abs(y-j),abs(ny-y+j))).^2);
obs=squeeze(psi(i,j,:));
obs_mean=psi_mean(i,j);

k1=[1 3 6 10 20 50 100];

for k=1:length(k1)-1;
	nens=2000;
	cova=zeros(nx,ny);
	varb=zeros(nx,ny);
	varo=0.0;
	for m=1:nens
		psifilt=kfilter(psi(:,:,m)-psi_mean,k1(k),k1(k+1));
		cova=cova+(obs(m)-obs_mean)*psifilt;
		varb=varb+psifilt.^2;
		varo=varo+(obs(m)-obs_mean)^2;
	end
	corr0=cova./sqrt(varo.*varb);

	nens=80;
	cova=zeros(nx,ny);
	varb=zeros(nx,ny);
	varo=0.0;
	for m=1:nens
		psifilt=kfilter(psi(:,:,m)-psi_mean,k1(k),k1(k+1));
		cova=cova+(obs(m)-obs_mean)*psifilt;
		varb=varb+psifilt.^2;
		varo=varo+(obs(m)-obs_mean)^2;
	end
	corr1=cova./sqrt(varo.*varb);

	%subplot(1,2,1)
	%contourf(corr0',-1:0.1:1,'linestyle','none'); caxis([-1 1])
	%axis equal; axis([1 256 1 256])
	%set(gca,'XTickLabel',[],'YTickLabel',[])
	%subplot(1,2,2)
	%contourf(corr1',-1:0.1:1,'linestyle','none'); caxis([-1 1])
	%axis equal; axis([1 256 1 256])
	%set(gca,'XTickLabel',[],'YTickLabel',[])
%saveas(gca,'~/html/1','pdf')

	corrdiff=corr1-corr0;
	for l=1:120
		SE(c,k,l)=mean(corrdiff(dist>=l & dist<l+1).^2);
	end
end

save('SE_kl','SE','-v7.3')
end
end

cmap=colormap(jet(length(k1)-1));
for k=1:length(k1)-1
	plot(1:120,smooth_1d(sqrt(mean(SE(:,k,:),1)),2),'color',cmap(k,:)); hold on 
	plot([60 80],[1 1]*(0.15-k*0.02),'color',cmap(k,:));
	text(85,0.15-k*0.02,['k=' num2str(k1(k)) '~' num2str(k1(k+1))],'fontsize',16)
end
xlabel('distance','fontsize',20)
ylabel('sampling error','fontsize',20)

saveas(gca,'~/html/1','pdf')
