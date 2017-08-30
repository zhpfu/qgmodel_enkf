function [qk,zetak,etak] = get_pv(psik,dz,rho,F,Fe);

% [qk,zetak,etak] = GET_PV(psik,dz,rho,F,Fe) 
%     Get spectral PV field from
%     spectral streamfunction field, psik.  Optionally returns
%     spectral relative vorticity, zetak, and vortex stretching, etak,
%     as well (qk = zetak + etak). Optional Fe is F for free surface.
%  
%     See also INVERT_PV.

nkx = size(psik,1);  nky = size(psik,2); nz = size(psik,3);
kmax = nky-1;

if length(dz)~=nz, error('Wrong number of levels.');, end

[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);
k2_ = kx_.^2+ky_.^2;
if nargin==4
  [a,b,c] = get_strat_params(dz,rho,F);
elseif nargin==5
  [a,b,c] = get_strat_params(dz,rho,F,Fe);
end
  
for n = 2:nz-1
   etak(:,:,n,:) = a(n).*psik(:,:,n-1,:) + (b(n)).*psik(:,:,n,:) ...
             + c(n).*psik(:,:,n+1,:);
end
etak(:,:,1,:)  = (b(1)).*psik(:,:,1,:) + c(1)*psik(:,:,2,:);
etak(:,:,nz,:) = (b(nz)).*psik(:,:,nz,:) + a(nz)*psik(:,:,nz-1,:);

for n = 1:nz
  for t = 1:size(psik,4)
    zetak(:,:,n,t) = -k2_.*psik(:,:,n,t);
  end
end

qk = zetak + etak;
