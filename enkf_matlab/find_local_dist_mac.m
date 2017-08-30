function roi = find_local_dist_mac(u,krange)

[nx ny nz nm]=size(u); 
nens=nm-1; 
ns=length(krange);

[x,y]=ndgrid(1:nx,1:ny);

for m=1:nens
	ums(:,:,:,m,:)=separate_scales(u(:,:,:,m),krange);
end

lv=2;
thin=4;
mac=zeros(nx,ny,ns);
for s=1:ns
	count=0;
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
		mac(:,:,s)=mac(:,:,s)+abs(cova./sqrt(vara.*varb));
		count=count+1;
	end
	end
end
mac=mac/count;

%expected mean abs corr
rng('shuffle');
ctrue=[1 0; 0 1]; mtrue=[0 0];
for i=1:count
  s=mvnrnd(mtrue,ctrue,nens);
  rho(i)=corr(s(:,1),s(:,2));
end
macex=std(rho);

%find distance
dist=sqrt((min(abs(x-1),abs(nx-x+1))).^2+(min(abs(y-1),abs(ny-y+1))).^2);
for s=1:ns
  for l=1:nx/2
    macs=mac(:,:,s);
    macl(l)=mean(macs(dist>=l & dist<l+1));
  end
  if(min(macl)<=macex)
    roi(s)=find(macl<=macex,1);
  else
    roi(s)=nx;
  end
end
