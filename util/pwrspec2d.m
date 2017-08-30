%Michael Ying 2015
function [wn pwr] = pwrspec2d(incr) 

pi=4.0*atan(1.0);

nz=1; nt=1;
[nx,ny,nz,nt] = size(incr);

FT = zeros(nx,ny,nz,nt);

%number of unique points
nupx = ceil((nx+1)/2); 
nupy = ceil((ny+1)/2);
nup=max(nupx,nupy); nup1=min(nupx,nupy);

if(mod(nx,2)==0)
	wnx=[0:nupx-1 2-nupx:-1];
else
	wnx=[0:nupx-1 1-nupx:-1];
end
if(mod(ny,2)==0)
	wny=[0:nupy-1 2-nupy:-1];
else
	wny=[0:nupy-1 1-nupy:-1];
end
[kx,ky]=ndgrid(wnx,wny);
k2d=sqrt(((kx.*(nup/nupx)).^2+(ky.*(nup/nupy)).^2)); %effective wavenumber k/n=kx/nx

%calculate spectrum
for k = 1:nz
for n = 1:nt
	FT(:,:,k,n) = fft2(incr(:,:,k,n));
end
end

P=abs(FT)/nx/ny;
P=P.*P;

%Pt = P(1:nupx,1:nupy,:,:);
%Pt(2:nupx-1,2:nupy-1,:,:) = P(2:nupx-1,2:nupy-1,:,:)*2 + P(2:nupx-1,JM:-1:JM-nupy+3,:,:)*2;
%Pt(1,2:nupy-1,:,:) = P(1,2:nupy-1,:,:) + P(1,JM:-1:JM-nupy+3,:,:);
%Pt(2:nupx-1,1,:,:) = P(2:nupx-1,1,:,:) + P(IM:-1:IM-nupx+3,1,:,:);

wn=0:ceil(max(k2d(:)));
nm=length(wn);
pwr = zeros(nm,nz,nt);
cnt=zeros(1,nm);

for i=1:nx
for j=1:ny
  m=ceil(k2d(i,j));
  pwr(m+1,:,:) = pwr(m+1,:,:) + permute(P(i,j,:,:),[2 3 4 1]);
  cnt(m+1)=cnt(m+1)+1;
end
end

wn=wn(1:nup);
pwr=pwr(1:nup,:,:);
