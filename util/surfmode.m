function [phi] = surfmode(dz,rho,F,K);

% [phi] = SURFMODE(dz,rho,F,K)  
%
%     Calculates the vertical profile of the surface QG mode at
%     horizontal wavenumber K = sqrt(k^2 + l^2), for arbitrary
%     potential density profile rho(n), corresponding to layers of
%     thickness dz(n), and with F=f0^2 (L/(2*pi))^2/(g'*H0).
%     Assumes unit surface buoyancy.  Specifically solves
%     d/dz(sigma*d phi/dz) - K^2*phi = delta(z), where sigma is a
%     finite differnce approximation to (d rho/dz)^(-1).
%
%     See also GET_STRAT_PARAMS

dz = dz(:);  rho = rho(:); nz = length(dz);

[a,b,c] = get_strat_params(dz,rho,F);

A = diag(a(2:nz),-1) + diag(b(1:nz)-K^2,0) + diag(c(1:nz-1),+1);

b = [1; zeros(nz-1,1)];

phi = A\b;

