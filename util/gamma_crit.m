function gammac = gamma_crit(dz,rho,u,v,F,kvec,lvec,gamma0,mindel);

% gammac = GAMMA_CRIT(dz,rho,u,F,kvec,gamma0,mindel)
%     Calculates the critical value of gamma to yield instability in
%     stratified QG with vertical discritization dz, density profile
%     rho, velocity profiles u and v, Froude number F, a vector of zonal
%     wavenumbers over which to search for instability kvec and initial
%     value of gamma gamma0.  The code doubles or halves gamma until
%     a positive growth rate is found or lost, and then successively 
%     splits the interval until the interval is lower than mindel,
%     at which point the value of gamma is passed as the result.
%     NOTE:  beta = F*gamma, and that gammacrit is largely independent 
%     of F (try CRITICAL_CURVE to  see variation of gamma with F).
%
%     See also CRITICAL_CURVE.

resid = 1e6*eps;
gamma=gamma0;
gr = qggr(dz,rho,u,v,F,gamma*F,0,0,1,kvec,lvec,0);
if max(gr)>resid;          % Scan up
   gamfactor = 2;
elseif max(gr)<=resid;     % Scan down
   gamfactor = 1/2;
end
scan = 1;                  % Logical flag -- keep scanning while scan==1
while scan==1
   gammaold = gamma;       % Store old value to make delgam after crossover
   gamma = gamma*gamfactor % Halve or double until find or lose gr
   gr = qggr(dz,rho,u,F,F*gamma,0,0,1,kvec,lvec,0);
   if ((gamfactor==2)&(max(gr)<=resid))|((gamfactor==1/2)&(max(gr)>resid))
      scan=-1;
   end
end
delgam=abs(gammaold-gamma);
while delgam>mindel
   delgam = delgam/2;
   if max(gr)>resid
      gamma = gamma + delgam
   elseif max(gr)<=resid
      gamma = gamma - delgam
   end
   gr = qggr(dz,rho,u,v,F,F*gamma,0,0,1,kvec,lvec,0);
end
gammac = gamma;
