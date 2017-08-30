function [a,b,c,dz,rho,drho] = get_w_params(dz,rho,F)

%  [a,b,c,dz,rho,drho] = GET_W_PARAMS(dz,rho,F)
%
%     Calculate tridiagonal components of vertical coupling
%     matrix for QG w equation.  If dz and rho called as output args,
%     returned values are normalized as in SQG model.  

nz = length(dz);

a=zeros(nz-1,1); b=zeros(nz-1,1); c=zeros(nz-1,1);

dz = dz/sum(dz);          % fractional layer thicknesses
drho = rho(2:nz)-rho(1:nz-1);
drho = drho/(sum(drho)/length(drho));

a(2:end)   = F./(dz(2:end-1).*drho(2:end));
c(1:end-1) = F./(dz(1:end-2).*drho(1:end-1));
b = -(F./drho).*(1./dz(1:end-1) + 1./dz(2:end));
