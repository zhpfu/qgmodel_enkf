function post=enkf_allscale(prior,prior_y,dat,localize_cutoff,obs_thin)

[nx ny nz nm]=size(prior); nens=nm-1;
[x,y,z]=ndgrid(1:nx,1:ny,1:nz);

%observation
nobs=size(dat,1);
obs_x=dat(:,1);
obs_y=dat(:,2);
obs_z=dat(:,3);
obserr=dat(:,4);
obs=dat(:,5);

%observation priors (hx)
for m=1:nens+1
  obs_prior(:,m)=interpn(x,y,prior_y(:,:,:,m),obs_x,obs_y);
end

%ensemble perturbation
u=prior; hu=obs_prior;
for m=1:nens
  u(:,:,:,m)=u(:,:,:,m)-prior(:,:,:,nens+1);
  hu(:,m)=hu(:,m)-obs_prior(:,nens+1);
end

%assimilation loop
for p=randperm(nobs)
%pind=reshape(1:nobs,[sqrt(nobs) sqrt(nobs)]);
%for j=1:obs_thin:sqrt(nobs)
%for i=1:obs_thin:sqrt(nobs)
%p=pind(i,j);
  innov=obs(p)-obs_prior(p,nens+1);

  %if(abs(innov)>(10*obserr(p)))
    %disp('kicked off')
    %continue
  %end

  dist=sqrt((min(abs(x-obs_x(p)),abs(nx-x+obs_x(p)))).^2+(min(abs(y-obs_y(p)),abs(ny-y+obs_y(p)))).^2);  %distance between y and x, cyclic bc
  loc=localization(dist,localize_cutoff);
  hdist=sqrt((min(abs(obs_x-obs_x(p)),abs(nx-obs_x+obs_x(p)))).^2+(min(abs(obs_y-obs_y(p)),abs(ny-obs_y+obs_y(p)))).^2);
  hloc=localization(hdist,localize_cutoff);

  uind=(dist<=localize_cutoff);
  huind=(hdist<=localize_cutoff);

  varb=sum(hu(p,1:nens).^2,2)./(nens-1);
  %varo=innov^2;
  varo=obserr(p)^2;
  d=varo+varb;
  alpha=1.0/(1.0+sqrt(varo/d));

  cova=zeros(nx,ny,nz);
  hcova=zeros(nobs,1);
  for m=1:nens
    utmp=u(:,:,:,m);
    cova(uind)=cova(uind)+hu(p,m)*utmp(uind);
    hutmp=hu(:,m);
    hcova(huind)=hcova(huind)+hu(p,m)*hutmp(huind);
  end
  cova=cova./(nens-1); 
  hcova=hcova./(nens-1);

  gain=loc.*cova./d;
  hgain=hloc.*hcova./d;

  for m=1:nens
    update=zeros(nx,ny,nz); 
    update(uind)=-alpha.*gain(uind).*hu(p,m);
    u(:,:,:,m)=u(:,:,:,m)+update;
    hupdate=zeros(nobs,1);
    hupdate(huind)=-alpha.*hgain(huind).*hu(p,m);
    hu(:,m)=hu(:,m)+hupdate;
  end
  update=zeros(nx,ny,nz);
  update(uind)=gain(uind).*innov;
  u(:,:,:,nens+1)=u(:,:,:,nens+1)+update;
  hupdate=zeros(nobs,1);
  hupdate(huind)=hgain(huind).*innov;
  hu(:,nens+1)=hu(:,nens+1)+hupdate;

%contourf(x,y,cova,'linestyle','none'); caxis([0 1]); pause(1)
%out(:,:,:,p)=cova.*loc;
%disp(sprintf('No%7i (%7.2f,%7.2f,%5.2f) %7.2f %7.2f %7.2f',p,obs_x(p),obs_y(p),obs_z(p),obs(p),obs_prior(p,nens+1),hu(p,nens+1)))
end
%end
%end

for m=1:nens
  post(:,:,:,m)=u(:,:,:,m)+u(:,:,:,nens+1);
end

%addpath /wall/s0/yxy159/graphics
%system('rm -f 1.nc');
%nc_write('1.nc','out',{'x','y','z','p'},out)
