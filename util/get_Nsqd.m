function Nsqd = get_Nsqd(dz,rho)

%    Nsqd = get_Nsqd(dz,rho) Calculate N^2 using same
%    discretization and nondimensionalization used for QG package.
%    Specifically, calculate N^2 at interfaces, so result has
%    dimension nz-1, where nz = length(dz) = length(rho).

nz = length(dz);

dz = dz/sum(dz);          % fractional layer thicknesses
Dz = (dz(1:end-1) + dz(2:end))/2;  % distance between layer centers

drho = rho(2:nz)-rho(1:nz-1);
drho = drho/(sum(drho)/length(drho));

Nsqd = drho./Dz;
