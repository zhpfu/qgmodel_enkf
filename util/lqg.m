function [w,evec] = lqg(dz,rho,U,V,F,beta,dc,nu,hve,k,l,vec);

% [w,evec] = LQG(dz,rho,U,V,F,beta,uscale,dc,nu,hve,k,l,vec)
%     Calculates the frequencies and eigenmodes (if vec = 1)
%     of the stratified QG model for a density profile, rho(z),
%     corresponding to layers of thickness dz(z), mean zonal
%     velocities U(z), and mean meridional velocities V(z).  
%     Velocities and densities are presumed to be specified at
%     layer centers.  Assumes rigid lid and flat bottom.
%     Requires F = f0^2 (L/(2*pi))^2/(g' H0), 
%     beta = beta0 (L/(2*pi))^2/U, zonal wavenumber k and 
%     meridional wavenumber l as inputs.  dc is drag coefficient 
%     (dc*del^2 psi on bottom layer only), nu is hyperviscosity 
%     coefficient and hve is hyperviscous exponent: 
%     hypervisc = nu*(del^2)^(hve+1) psi. 
%
%     See also QGGR, EIG.

dz = dz(:);  rho = rho(:);  U = U(:);  V = V(:);
nz = length(dz);
k2 = k^2+l^2;

[a,b,c]   = get_strat_params(dz,rho,F);

Q_y       = beta - get_shear(a,b,c,U);
Q_x       = get_shear(a,b,c,V); 
Udot_grad = k*U + l*V;
dot_gradQ = k*Q_y - l*Q_x;

drag      = [zeros(nz-1,1); i*dc*k2];
hvisc     = -i*nu*k2^hve*ones(nz,1);

A =  diag( (Udot_grad(2:nz) + hvisc(2:nz)).*a(2:nz),      -1) ...
   + diag( (Udot_grad + hvisc).*(b-k2) + dot_gradQ + drag, 0) ...
   + diag( (Udot_grad(1:nz-1) + hvisc(1:nz-1)).*c(1:nz-1), 1);

B =  diag(a(2:nz),-1) + diag(b-k2,0) + diag(c(1:nz-1),1);

if vec==1
  [evec,D] = eig(A,B);  % Solves   A x = lambda B x
  w = diag(D);
elseif vec==0
  evec = 0;
  w = eig(A,B);
else
   error('Vec must be 0 or 1 (in lqg)')
end
