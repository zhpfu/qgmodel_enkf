function [fi,k] = iso_spectra(fk,kimax);

% [fi,k] = ISO_SPECTRA(fk,kimax) 
%     Sum (integrate..) an upper-half plane spectral field over 
%     isotropic wavenumer (result is multiplied by 2 to get full
%     answer).  Optional input kimax
%     is the maximum isotropic wavenumber for which to calculate
%     spectra (default is kmax = nky-1).  Also produces vector of 
%     isotropic wavenumbers, k.
%
%     See also FULLSPEC.

nkx = size(fk,1); nky = size(fk,2);  nz = size(fk,3); nt = size(fk,4);
kmax = nky-1;

if nargin < 2
   kimax = kmax;
end

[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);
k_ = sqrt(kx_.^2+ky_.^2);
fi = zeros(kimax,nz,nt);
k  = 0:kimax-1;

for i = 1:nkx
  for j = 1:nky
     arind=fix(k_(i,j)+.5);
     if ((arind~=0)&(arind<=kimax))
       fi(arind,:,:) = squeeze(fi(arind,:,:)) ...
	   + squeeze(shiftdim(conj(fk(i,j,:,:)),1));
     end
  end
end 

fi = 2*fi;
