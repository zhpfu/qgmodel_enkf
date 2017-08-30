addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/highres2';

kmax=199;
nt=500;
intv=10;

for t=1:nt
  psik=read_field([workdir '/truth/' sprintf('%5.5i',t)],2*kmax+1,kmax+1,2,1);
  psi=spec2grid(psik);
  psik1=grid2spec(psi(1:intv:end,1:intv:end,:));
  write_field(psik1,[workdir '/truth1/' sprintf('%5.5i',t)],1);
end
