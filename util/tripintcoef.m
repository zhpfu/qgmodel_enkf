function [e,kd,evec] = tripintcoef(dz,rho,F);

% [e,kd,evec] = TRIPINTCOEF(dz,rho,F)  
%     Calculates the triple interaction 
%     coefficient, e_ijk = integral(F_i*F_j*F_k)dz, where F_i 
%     are the vertical modes for the given stratification 
%     (obtained from 'vmodes.m').  With this coefficient, one can 
%     calculate the advective energy flux for a given mode,
%     dE_m/dt = integral(sum_jk(e_mjk*J(psi_m,psi_j)*q_k))dx*dy, or
%     the potential enstrophy budget (see Hua and Haidvogel, 86,
%     JPO v.43).
%
%     NOTE:  NOT GOOD - THIS ONE GETS THE HIGHER COEFFS WRONG
%     DUE TO ALIASING...
%
%     See also TRIPINTCOEF2, VMODES.

nz = length(dz);
dz = dz/sum(dz);          % fractional layer thicknesses

[kd,evec] = vmodes(dz,rho,F);

for i = 1:nz
  for j = 1:nz
    for k = 1:nz
      e(i,j,k) = sum(dz.*evec(:,i).*evec(:,j).*evec(:,k));
    end
  end
end

