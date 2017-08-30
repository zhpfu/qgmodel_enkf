addpath enkf
nens=40;

for m=1:nens
  psik=read_field(['qg1/ensemble_msl/' sprintf('%4.4i',m) '/f_00009'],127,64,2,1);
  psi(:,:,:,m)=spec2grid(psik);
end
psi(:,:,:,nens+1)=mean(psi(:,:,:,1:nens),4);

u=psi;
for m=1:nens
  u(:,:,:,m)=u(:,:,:,m)-u(:,:,:,nens+1);
end

roi=find_local_dist_mac(u,[2 4 8 20])
roi=find_local_dist(u,[2 4 8 20])
