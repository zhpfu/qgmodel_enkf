clear all

addpath util;
rng('shuffle');
pi=4.0*atan(1.0);

kmax=63; nz=2;
nkx=2*kmax+1;
nky=kmax+1;

w=1:kmax; p=1e0*w.^(-3);
[kx,ky]=ndgrid(-kmax:kmax,0:kmax); kk=sqrt(kx.^2+ky.^2);

  ukz=zeros(2*kmax+1,kmax+1);
  vkz=ukz;
  for k=1:kmax
	  ind=(kk>=k & kk<k+1);
    phase=rand(nkx,nky);
  	ukz(ind)=sqrt(p(k)/k)*exp(2*sqrt(-1)*pi*phase(ind));
    phase=rand(nkx,nky);
  	vkz(ind)=sqrt(p(k)/k)*exp(2*sqrt(-1)*pi*phase(ind));
  end
  uk=ukz;
  vk=vkz;

psik(:,:,1)=zeta2psi(uv2zeta(uk,vk));
psik(:,:,2)=zeta2psi(uv2zeta(uk,vk));
system('rm -rf ic.bin');
write_field(psik,'ic',1);
