function fz = ddzm(f,dz,rho,res)

% fz = DDZM(f,dz,rho)  Calculates vertical derivative at same discretization 
%     points as f is specified on.  Uses high resolution
%     interpolation onto vertical modes.
%
% See also:  DVMODEDZ_COEFS, LAYER2MODE

[kd,vmode] = vmodes(dz,rho,1);
fz = vmode*dvmodedz_coefs(dz,rho,res)*((f(:).*dz(:))'*vmode)'

%fm = (f.*dz)'*evec;
%fzm = a*fm(:);
%fz = evec*fzm(:);
