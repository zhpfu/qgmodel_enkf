%EnKF program  - Yue Ying 2016
%
%  prior(nx,ny,nz,nens+1)    prior ensemble and mean
%  post                      posterior ensemble and mean (output)
%  dat(nobs,5)               observation 'x,y,z,obs err,obs value'
%
%  Parameters:
%  localize = 0     no localization
%             1     specified localization ROI
%             2     adaptively specified ROI with sample corr
%  roi              localization ROI, omitted if localize=0,2
%  krange           wavenumber band specified for scale decomposition
%  obs_thin         observation thinning

function post=enkf(prior,dat,localize,roi,krange,obs_thin)

[nx ny nz nm]=size(prior); 
nens=nm-1; 
ns=length(krange);

[x,y,z]=ndgrid(1:nx,1:ny,1:nz);

%observation
nobs=size(dat,1);
obs_x=dat(:,1);
obs_y=dat(:,2);
obs_z=dat(:,3);
obserr=dat(:,4);
obs=dat(:,5);

u=prior; 
%ensemble perturbation
for m=1:nens
  u(:,:,:,m)=u(:,:,:,m)-u(:,:,:,nens+1);
end

%use adaptive algorithm to specify localization ROI
if(localize==2)
  roi=find_local_dist_mac(u,krange)
end

%assimilation loop
%for p=1:obs_thin:nobs %randperm(1:obs_thin:nobs)
pind=reshape(1:nobs,[sqrt(nobs) sqrt(nobs)]);
for j=1:obs_thin:sqrt(nobs)
for i=1:obs_thin:sqrt(nobs)
p=pind(i,j);

    for m=1:nens+1
      hu(m)=obs_operator(x,y,z,u(:,:,:,m),obs_x(p),obs_y(p),obs_z(p));
    end

    innov=obs(p)-hu(nens+1);

    varb=sum(hu(1:nens).^2)./(nens-1);
    %varo=innov^2; %AOEI
    varo=obserr(p)^2;
    d=varo+varb;
    alpha=1.0/(1.0+sqrt(varo/d));

  %distance between obs_location and x, consider cyclic bc
  dist=sqrt((min(abs(x-obs_x(p)),nx-abs(x-obs_x(p)))).^2+(min(abs(y-obs_y(p)),ny-abs(y-obs_y(p)))).^2);  

  %scale separation
  for m=1:nens+1
    u_ms(:,:,:,m,:)=separate_scales(u(:,:,:,m),krange);
  end

  for s=1:ns
    if(localize==0) %no localization
      loc=ones(size(dist));
      uind=(dist>=0);
    else
      loc=localization(dist,roi(s));
      uind=(dist<=roi(s));
    end

    cova=zeros(nx,ny,nz);
    for m=1:nens
      utmp=u_ms(:,:,:,m,s);
      cova(uind)=cova(uind)+hu(m)*utmp(uind);
    end
    cova=cova./(nens-1);
    gain=loc.*cova./d;

    for m=1:nens
      update=zeros(nx,ny,nz); 
      update(uind)=-alpha.*gain(uind).*hu(m);
      u_ms(:,:,:,m,s)=u_ms(:,:,:,m,s)+update;
    end
    update=zeros(nx,ny,nz);
    update(uind)=gain(uind).*innov;
    u_ms(:,:,:,nens+1,s)=u_ms(:,:,:,nens+1,s)+update;
  end

  %sum all scales
  u=sum(u_ms,5);

  %contourf(x,y,cova,'linestyle','none'); caxis([0 1]); pause(1)
	disp(sprintf('No%7i (%7.2f,%7.2f,%5.2f) %7.2f',p,obs_x(p),obs_y(p),obs_z(p),obs(p)))

end
end
%end

post=zeros(nx,ny,nz,nm);
for m=1:nens
  post(:,:,:,m)=u(:,:,:,m)+u(:,:,:,nens+1);
end
post(:,:,:,nens+1)=u(:,:,:,nens+1);

