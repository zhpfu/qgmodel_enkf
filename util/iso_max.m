function [fiso,k] = iso_max(fk,kxvec,kyvec);

% [fiso,k] = ISO_MAX(fk,kx,ky) 
%     Max values of a spectral field over
%     isotropic wavenumer.  kxvec and kyvec are 1d spectral
%     coordinates for fk.  Also returns vector of isotropic
%     wavenumbers, k.

nkx = size(fk,1); nky = size(fk,2);

if length(kxvec)~=nkx, error('Wrong size kxvec'), end
if length(kyvec)~=nky, error('Wrong sixe kyvec'), end
   
[kx_,ky_] = ndgrid(kxvec,kyvec);
k_ = sqrt(kx_.^2+ky_.^2);
[v,izero] = min(abs(kxvec));
[w,jzero] = min(abs(kyvec));
if (v~=0|w~=0), warning('Spectra not centered on zero'), end;
nk = 1+fix(sqrt(length(izero:nkx)^2+length(jzero:nky)^2))
fiso = zeros(nk,1);
delk = kxvec(nkx)-kxvec(nkx-1)
k = delk*(0:nk-1)+delk/2;        % Effective k value for ring k:k+delk

for i = 1:nkx
  for j = 1:nky
     ind = 1+fix(k_(i,j)/delk);
     fiso(ind) = fiso(ind)+fk(i,j);
  end
end