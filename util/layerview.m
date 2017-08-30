function h = layerview(psi,delz,rho,hb,F,r)

% h = LAYERVIEW(psi,delz,rho,hb,F,r)
%     Calculate properly scaled layer interface heights.  
%     Plots the surfaces h(n) = z(n) + r*F*eta(n), n=1,nz-1,
%     h(nz) = -1 + r*hb, where F is F from the model, r is 
%     an estimate of the rossby number, hb is the bottom 
%     topography and eta(n) = (psi(n+1)-psi(n))/(rho(n+1)-rho(n)).
%     NOTE:  should add a term for mean U...

nz = size(psi,3);

if nargin<4, hb=0.; end
zl = -cumsum(delz);

for n = 1:nz-1
  h(:,:,n) = zl(n)+r*F*(psi(:,:,n+1)-psi(:,:,n))./(rho(n+1)-rho(n));
end

h(:,:,nz) = -1+r*hb;