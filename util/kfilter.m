function dat_filtered=kfilter(dat,kmin,kmax)

[nx,ny,nz]=size(dat);

if(mod(nx,2)==0)
  kx1=[0:ceil((nx-1)/2) -ceil((nx-1)/2)+1:-1];
else
  kx1=[0:ceil((nx-1)/2) -ceil((nx-1)/2):-1];
end
if(mod(ny,2)==0)
  ky1=[0:ceil((ny-1)/2) -ceil((ny-1)/2)+1:-1];
else
  ky1=[0:ceil((ny-1)/2) -ceil((ny-1)/2):-1];
end
[kx,ky]=ndgrid(kx1,ky1);
n=max(nx,ny);
kk=sqrt(((kx.*(n/nx)).^2+(ky.*(n/ny)).^2)); %effective wavenumber k/n=kx/nx

flt(1:nx,1:ny)=0;
flt(kk>=kmin & kk<kmax)=1;

for z=1:nz
	FT=fft2(squeeze(dat(:,:,z)));
	FT=FT.*flt;
	dat_filtered(:,:,z)=real(ifft2(FT));
end

