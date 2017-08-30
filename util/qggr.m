function [wi_max,wr_max,amp,phase,psi] = ...
   qggr(dz,rho,U,V,F,beta,dc,nu,hve,kvec,lvec)

%  [wi_max,wr_max,amp,phase,psi] = QGGR(dz,rho,U,V,F,beta,dc,nu,hve,kvec,lvec)
%     Calculates the growth rate for the stratified QG model 
%     with a density profile, rho(n), corresponding to 
%     layers of thickness dz(n), and mean velocities 
%     U(n) and V(n).  Needs F = f0^2 L^2/(g H0), beta = beta0 L^2/U.
%     Produces array wi_max(range,range) of maximum growth rates (wrt
%     vertical wavenumber) for each wavenumber pair (k,l), where
%     k,l : [kvec,lvec] (integers), and returns corresponding real
%     part of frequency, wr_max.  Uses lqg.m to get frequencies.
%     Finally, gives optional amplitude and phase of the
%     eigenfunction which corresponds to wi_max for each k,l, and
%     stores them in 3d arrays amp(l,k,:) and phase(l,k,:). 
%
%     See also LQG.

dz = dz(:); rho = rho(:); U = U(:); V = V(:);

nkx = length(kvec);  nky = length(lvec); nz = length(dz);

wi_max = zeros(nkx,nky);  
wr_max  = zeros(nkx,nky);

vec=0;
if nargout >= 3      % for amp and phase, need to collect evectors.
   amp   = zeros(nkx,nky,nz);
   phase = zeros(nkx,nky,nz);
   psi   = zeros(nkx,nky,nz);
   vec   = 1;
end

kc = 1;
for k = kvec
  lc = 1;
  for l = lvec
     [w,evec] = lqg(dz,rho,U,V,F,beta,dc,nu,hve,k,l,vec);
     if max(abs(imag(w))) > eps
        [wi_max(kc,lc),ind] = max(imag(w));
        wr_max(kc,lc) = real(w(ind));
     else
        [wr_max(kc,lc),ind] = max(real(w));
        wi_max(kc,lc) = imag(w(ind));
     end
     if vec ==1
        amp(kc,lc,:)   = sqrt(real(evec(:,ind)).^2+imag(evec(:,ind)).^2);
        phase(kc,lc,:) = ...
	    atan2(imag(evec(:,ind)),real(evec(:,ind)));
	psi(kc,lc,:) = evec(:,ind);
     end
     lc = lc+1;
  end
  kc = kc+1;
end

