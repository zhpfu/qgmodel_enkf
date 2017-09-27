addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/TN64';

kmax=63; nx=2*(kmax+1);
nt=300;
dx=2;

for t=1:nt
  psik=read_field([workdir '/truth/' sprintf('%5.5i',t)],2*kmax+1,kmax+1,2,1);
  psi=spec2grid(psik);
  psik1=grid2spec(psi(1:dx:end,1:dx:end,:));
  write_field(psik1,[workdir '/truth1/' sprintf('%5.5i',t)],1);
end

