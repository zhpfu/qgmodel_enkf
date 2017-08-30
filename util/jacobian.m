function [jack,jac] = jacobian(fk,gk);

% [jack,jac] = jacobian(fk,gk)  Computes jacobian of SPECTRAL fields
%     fk and gk by transforming their derivatives, fk_x, fk_y,
%     gk_x and gk_y, to physical space, computing the physical 
%     products, f_x*g_y and f_y*g_x, then transforming each 
%     product back to spectral space, and taking the difference, 
%     jac = fk_x*gk_y - fk_y*gk_x.  
%
%     See also SPEC2GRID, GRID2SPEC.

[nkx,nky,nz] = size(fk);
kmax = nky-1;

if (nkx~=size(gk,1) | nky~=size(gk,2) | nz ~= size(gk,3))
  error('Mismatched field sizes...')
end
if (nkx+1~=nky*2) 
   error('These are not spectral fields.')
end
 
kmaxh = 3*(kmax+1)/2-1;
fhk = zeros(2*kmaxh+1,kmaxh+1,nz);
ghk = zeros(2*kmaxh+1,kmaxh+1,nz);

fhk(kmaxh+1-kmax:kmaxh+1+kmax,1:kmax+1,:) = fk;
ghk(kmaxh+1-kmax:kmaxh+1+kmax,1:kmax+1,:) = gk;
 
[kx_,ky_] = ndgrid(-kmaxh:kmaxh,0:kmaxh,1:nz);

f_x = spec2grid(fhk.*kx_*i);
f_y = spec2grid(fhk.*ky_*i);
g_x = spec2grid(ghk.*kx_*i);
g_y = spec2grid(ghk.*ky_*i);

jac = f_x.*g_y-f_y.*g_x;
jachk = grid2spec(jac);

jack = jachk(kmaxh+1-kmax:kmaxh+1+kmax,1:kmax+1,:);




