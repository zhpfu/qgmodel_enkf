function dat_scales=separate_scales(dat,krange)

[nx,ny,nz]=size(dat);

if(length(krange)==1)

  dat_scales=dat;

else

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

  for s=1:length(krange)
    flt=scale_response(kk,krange,s);
    for z=1:nz
      FT=fft2(squeeze(dat(:,:,z)));
      FT=FT.*flt;
      dat_scales(:,:,z,s)=real(ifft2(FT));
    end
  end

end
