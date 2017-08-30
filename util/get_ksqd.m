function [k2_,kx_,ky_] = get_ksqd(kmax,nz);

%  [k2_,kx_,ky_] = GET_KSQD(kmax,nz) 
%     Produces 2d or 3d field containing values of 
%     K^2 = (kx^2 + ky^2) on grid specified by kmax 
%     kx = [-kmax:kmax], ky = [0,kmax].

if (nargin==1) nz=1; end

[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax,1:nz);
k2_ = kx_.^2+ky_.^2;
