function [psi] = invert_pv_col(qk,K,dz,rho,F);

% [psi] = INVERT_PV(q,K,dz,rho,F)  
%     Inverts column of q values at given wavenumber K
%     from SQG model to get spectral psik field.  Uses layer
%     thicknesses, dz, densities, rho, and Froude number, F.
%
%     See also GET_PV.

% Method of inversion is a vectorized form of the routine 'TRIDIAG'
% in Numerical recipes.

nz = length(qk);

if length(dz)~=nz
  error('Wrong number of levels...')
end

k2_ = K^2;

[a,b,c] = get_strat_params(dz,rho,F);

gamma_ = zeros(size(qk)); psi = zeros(size(qk));

bet_ = b(1) - k2_;
psi(1) = qk(1)./bet_;
for n = 2:nz
   gamma_(n)= c(n-1)./bet_;
   bet_ = b(n) - k2_ - a(n)*gamma_(n);
   if any(bet_==0), error('singular inversion'), end 
   psi(n) = (qk(n)-a(n)*psi(n-1))./bet_;
end
for n = nz-1:-1:1
   psi(n) = psi(n) -gamma_(n+1).*psi(n+1);
end
