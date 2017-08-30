function [a,b,c,dz,rho,drho] = get_strat_params(dz,rho,F,Fe)

%  [a,b,c,dz,rho,drho] = GET_STRAT_PARAMS(dz,rho,F,Fe)
%
%     Calculate tridiagonal components of vertical coupling
%     matrix for QG.  If dz and rho called as output args,
%     returned values are normalized as in SQG model.  Optional Fe
%     sets F for free surface.

nz = length(dz);

a=zeros(nz,1); b=zeros(nz,1); c=zeros(nz,1);

dz = dz/sum(dz);          % fractional layer thicknesses
drho = rho(2:nz)-rho(1:nz-1);
drho = drho/(sum(drho)/length(drho));

a(2:nz)   = F./(dz(2:nz).*drho);
c(1:nz-1) = F./(dz(1:nz-1).*drho);
b(1)      = -c(1);
b(nz)     = -a(nz);
if nz>2 
   b(2:nz-1) = -a(2:nz-1)-c(2:nz-1);
end
if (nargin==4)
   b(1) = b(1) - Fe/dz(1);
end