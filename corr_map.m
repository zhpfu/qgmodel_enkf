addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/qgmodel_enkf/enkf_matlab
workdir='/glade/scratch/mying/qgmodel_enkf';

close all
getparams([workdir '/' expname '/truth']);

system(['mkdir -p ' workdir '/mcorr/' expname])

thin=3;
n1=1; nt=30; dt=1;
lv=1;
krange=1; %[0 5 21]; 

for n=1:floor((nt-n1)/dt)+1
nid=sprintf('%5.5i',n1+(n-1)*dt)

for m=1:nens
	psik=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/f_' nid],nkx,nky,nz,1);
	prior(:,:,:,m)=spec2grid(psik);
	prior1(:,:,:,m)=spec2grid(psi2u(psik));
end
prior(:,:,:,nens+1)=mean(prior(:,:,:,1:nens),4);
prior1(:,:,:,nens+1)=mean(prior1(:,:,:,1:nens),4);

u=prior; v=prior1;
for m=1:nens
  u(:,:,:,m)=u(:,:,:,m)-u(:,:,:,nens+1);
  v(:,:,:,m)=v(:,:,:,m)-v(:,:,:,nens+1);
end

[x,y]=ndgrid(1:nx,1:ny);

corrcount=zeros(length(krange),nx/2);

c=0;
for i=1:thin:nx
for j=1:thin:ny
c=c+1; 
dist=sqrt((min(abs(x-i),abs(nx-x+i))).^2+(min(abs(y-j),abs(ny-y+j))).^2);

%scale separation
for m=1:nens+1
  u_ms(:,:,:,m,:)=separate_scales(u(:,:,:,m),krange);
  v_ms(:,:,:,m,:)=separate_scales(v(:,:,:,m),krange);
end

for s=1:length(krange);
	cova=zeros(nx,ny);
	varb=zeros(nx,ny);
	varo=0.0;
	for m=1:nens
		ufilt=u_ms(:,:,lv,m,s);
    ofilt=v(i,j,lv,m);
    cova=cova+ufilt*ofilt;
		varb=varb+ufilt.^2;
    varo=varo+ofilt^2;
	end
	corr=cova./sqrt(varo.*varb);

	%subplot(3,3,c)
	%contourf(corr',-1:0.1:1,'linestyle','none'); caxis([-1 1]); hold on 
	%text(i,j,'+','color',[.0 .0 .0],'fontsize',14,'horizontalalignment','center')
	%axis equal; axis([1 nx 1 ny])
	%set(gca,'XTickLabel',[],'YTickLabel',[])

	for l=0:nx/2
		mcorr(n,c,s,l+1)=mean(abs(corr(dist>=l & dist<l+1)));
	end
end %s

end %j
end %i

save([workdir '/mcorr/' expname '/' casename],'mcorr','-v7.3')
end %n

