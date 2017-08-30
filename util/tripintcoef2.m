function e = tripintcoef2(nz,ptype,delrho,deltc);

% e = TRIPINTCOEF2(nz,ptype,delrho,deltc,F)  
%     Calculates the triple interaction 
%     coefficient, e_ijk = integral(F_i*F_j*F_k)dz, where F_i 
%     are the vertical modes for the given stratification 
%     (obtained from 'vmodes.m').  With this coefficient, one can 
%     calculate the advective energy flux for a given mode,
%     dE_m/dt = integral(sum_jk(e_mjk*J(psi_m,psi_j)*q_k))dx*dy, or
%     the potential enstrophy budget (see Hua and Haidvogel, 86,
%     JPO v.43)
%
%     NOTE:  This one works but relies on using a stratification
%     type set by GET_STRATIFICATION instead of interpolation for
%     an arbitrary input function.
%
%     See also VMODES, GET_STRATIFICATION.

res = 3;  % How many times higher res than 'nz'
[dz,rho] = get_stratification(res*nz,ptype,delrho,deltc);
[kz,evec] = vmodes(dz,rho,1);

for i = 1:nz
  for j = 1:nz
    for k = 1:nz
      e(i,j,k) = sum(dz.*evec(:,i).*evec(:,j).*evec(:,k));
    end
  end
end

e = e(1:nz,1:nz,1:nz);  % Keep only relevant part of tensor