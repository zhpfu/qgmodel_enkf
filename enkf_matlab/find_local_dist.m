function roi = find_local_dist(u,krange)

[nx ny nz nm]=size(u); 
nens=nm-1; 
ns=length(krange);

[x,y]=ndgrid(1:nx,1:ny);

for m=1:nens
	ums(:,:,:,m,:)=separate_scales(u(:,:,:,m),krange);
end

bins=-1:0.1:1;
chi2max=chi2inv(0.95,length(bins)-1);

%expected sample corr dist
rng('shuffle');
ctrue=[1 0; 0 1]; mtrue=[0 0];
for i=1:nx*ny
  s=mvnrnd(mtrue,ctrue,nens);
  rho(i)=corr(s(:,1),s(:,2));
end
ksd0=ksdensity(rho,bins);

dist=sqrt((min(abs(x-1),abs(nx-x+1))).^2+(min(abs(y-1),abs(ny-y+1))).^2);
lv=2;
thin=4;
for s=1:ns
  count=zeros(nx/2);
	for i=1:thin:nx
	for j=1:thin:ny
		cova=zeros(nx,ny);
		vara=zeros(nx,ny); varb=0.0;
		for m=1:nens
			ua=ums(mod(i-1:i+nx-2,nx)+1,mod(j-1:j+ny-2,ny)+1,lv,m,s); 
			ub=u(i,j,lv,m);
			cova=cova+ua*ub;
			vara=vara+ua.^2; varb=varb+ub^2;
		end
		corrs=cova./sqrt(vara.*varb);

    for l=1:nx/2
      tmp=corrs(dist>=l & dist<l+1);
      ntmp=length(tmp(:));
      corrsamp(count(l)+(1:ntmp),l)=tmp(:);
      count(l)=count(l)+ntmp;
    end
	end
	end

  for l=1:nx/2
    ksd=ksdensity(corrsamp(1:count(l),l),bins);
    chi2(l)=sum((ksd-ksd0).^2./ksd0);
  end

  roi(s)=find(chi2<=chi2max,1);
end

