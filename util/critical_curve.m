function gammac = critical_curve(delz,rho,u,Fvec,kvec,gamma0,...
   delgam0,mindel);

% gammac = CRITICAL_CURVE(delz,rho,u,Fvec,kvec,gamma0,delgam0,mindel)
%     Calculate critical instability curve as a function of gamma.
%
%     See also GAMMA_CRIT.

n=length(Fvec);
gamma=gamma0;
for j=1:n
   gammac(j)=gamma_crit(delz,rho,u,Fvec(j),kvec,gamma,delgam0,mindel)
   gamma=gammac(j);
end
