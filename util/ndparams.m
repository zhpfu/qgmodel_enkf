function [F,gamma,rossby,k_beta] = ndparams(L,H,U,phi,drho)

% [F,gamma,rossby,k_beta] = NDPARAMS(L,H,U,phi,drho) 
%     Gets nondimensional parameters (a la Pedlosky) from the MKS 
%     dimensional inputs.  
%     gamma=beta/F, which is independant of L.  k_beta = sqrt(beta).
%     F includes g' = g*drho (so drho is _average_ drho from layer to
%     layer).

% Dimensional parameters
g = 9.81;	% m/s^2
R = 6378000;	% m
omega = 7.27*10^(-5);                 % s^(-1)	
f0 = 2*omega*sin(phi*2*pi/360);       % s^(-1)
beta0 = 2*omega*cos(phi*2*pi/360)/R;  % (ms)^(-1)

% Nondimensional parameters
F      = f0.^2.*L.^2./(4*pi^2*g*drho*H);
beta   = beta0.*L.^2./(4*pi^2*U);
rossby = U*2*pi./(f0.*L);
k_beta = sqrt(beta);
gamma  = beta/F;
