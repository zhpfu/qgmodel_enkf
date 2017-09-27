addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/TN64';

kmax=63; nx=2*(kmax+1);
nt=300;
dx=2.9767;

[x,y,z]=ndgrid(0:nx,0:nx,1:2);
[x1,y1,z1]=ndgrid(0:dx:nx,0:dx:nx,1:2);

for t=1:nt
  psik=read_field([workdir '/truth/' sprintf('%5.5i',t)],2*kmax+1,kmax+1,2,1);
  a(1:nx,1:nx,:)=spec2grid(psik);
  a(nx+1,:,:)=a(1,:,:); a(:,nx+1,:)=a(:,1,:);
  psi1=interpn(x,y,z,a,x1,y1,z1);
  psik1=grid2spec(psi1);
  write_field(psik1,[workdir '/truth1/' sprintf('%5.5i',t)],1);
end

