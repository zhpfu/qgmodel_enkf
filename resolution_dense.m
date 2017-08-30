addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/run1';

kmax=99;
nx=2*(kmax+1); nx1=2*nx; 
nens=40;

[x,y,z]=ndgrid(1:2:2*nx+2,1:2:2*nx+2,1:2);
[x1,y1,z1]=ndgrid(1:nx1,1:nx1,1:2);

for t=1
for m=1:nens
  psik=read_field([workdir '/noda/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',t)],2*kmax+1,kmax+1,2,1);
  a(1:nx,1:nx,:)=spec2grid(psi2zeta(psik));
  a(nx+1,:,:)=a(1,:,:); a(:,nx+1,:)=a(:,1,:);
  a1=interpn(x,y,z,a,x1,y1,z1);
  psik1=zeta2psi(grid2spec(a1));
  write_field(psik1,[workdir '/noda1/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',t)],1);
end
end
