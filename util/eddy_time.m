function tau = eddy_time(psik,delz)

% tau = EDDY_TIME(psik,delz)  Calculates eddy turnaroud time 
%     from spectral relative vorticity field zetak (calculated  
%     from call to GET_VORTICITY) using particular definition 
%     tau = 2*pi/zeta_rms.
%
%     See also GET_VORTICITY.

zetak = psi2zeta(psik);
zetakf = fullspec(zetak);

nkx = size(zetakf,1); nky = size(zetakf,2); 
delz=delz/sum(delz);
[x_,y_,delz_] = ndgrid(1:nkx,1:nky,delz);
  
zeta_rms = sqrt(sum(sum(sum(delz_.*zetakf.*conj(zetakf)))));
tau = 2*pi/zeta_rms;
