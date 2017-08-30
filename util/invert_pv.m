function [psik] = invert_pv(qk,dz,rho,F);

% [psik] = INVERT_PV(qk,dz,rho,F)  
%     Inverts spectral qk field
%     from SQG model to get spectral psik field.  Uses layer
%     thicknesses, dz, densities, rho, and Froude number, F.
%
%     See also GET_PV.

% Method of inversion is a vectorized form of the routine 'TRIDIAG'
% in Numerical recipes.

nkx = size(qk,1);  nky = size(qk,2); nz = size(qk,3);
kmax = nky-1;

if length(dz)~=nz
  error('Wrong number of levels...')
end
if (nkx+1 ~= 2*nky) 
   error('Not a spectral input field.')
end

[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);
k2_ = kx_.^2+ky_.^2;
k2_(kmax+1,1) = 1;    % artificially set irrelevant point to 1 to 
                      % avoid singularity in inversion

[a,b,c] = get_strat_params(dz,rho,F);

gamma_ = zeros(size(qk)); psik = zeros(size(qk));

bet_ = b(1) - k2_;
psik(:,:,1) = qk(:,:,1)./bet_;
for n = 2:nz
   gamma_(:,:,n)= c(n-1)./bet_;
   bet_ = b(n) - k2_ - a(n)*gamma_(:,:,n);
   if any(bet_==0), error('singular inversion'), end 
   psik(:,:,n) = (qk(:,:,n)-a(n)*psik(:,:,n-1))./bet_;
end
for n = nz-1:-1:1
   psik(:,:,n) = psik(:,:,n) -gamma_(:,:,n+1).*psik(:,:,n+1);
end
