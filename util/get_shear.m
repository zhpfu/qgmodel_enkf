function S = get_shear(a,b,c,ubar);

% S = GET_SHEAR(a,b,c,ubar)
%     Calculate shear (S) from tridiagonal matrix coefficients (a,b,c -
%     output from GET_STRAT_PARAMS) and mean zonal velocity (ubar).
%
%     See also GET_STRAT_PARAMS.

nz = length(ubar);

S(1)      = b(1)*ubar(1) + c(1)*ubar(2);
S(nz)     = a(nz)*ubar(nz-1) + b(nz)*ubar(nz);
if (nz>2)
   S(2:nz-1) = a(2:nz-1).*ubar(1:nz-2) ...
             + b(2:nz-1).*ubar(2:nz-1) ...
             + c(2:nz-1).*ubar(3:nz);
end

S=S(:);