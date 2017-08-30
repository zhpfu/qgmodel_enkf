function [jk,jg,jgs,Wk] = jacobk(psik,qk)

% [jk] = jacobk(psik,qk)  Calculate dealiased spectral jacobian
% using same method as QG code.

% Initial parameters

i      = sqrt(-1);
kmax   = size(psik,2)-1;
ngrid  = 2*(kmax+1);
ngrid2 = ngrid^2;

% Wavenumber vectors, grid-shift arrays and dealiasing mask

[kx_,ky_] = ndgrid(-kmax:kmax,0:kmax);
alphak    = exp(i*pi*(kx_+ky_)/ngrid);
alphakf   = fullspec(alphak);
damask    = get_mask(kmax);

% Calculate derivatives in k-space and make packed k-space arrays

psikxa = fullspec(gradk(damask.*psik,1)).*(1 + i*alphakf);
psikya = fullspec(gradk(damask.*psik,2)).*(1 + i*alphakf);
qkxa   = fullspec(gradk(damask.*qk  ,1)).*(1 + i*alphakf);
qkya   = fullspec(gradk(damask.*qk  ,2)).*(1 + i*alphakf);

% Get complex to complex transforms (imag parts of results are
% derivatives on the staggered grid)

psixa = ngrid2*ifft2(ifftshift(psikxa));
psiya = ngrid2*ifft2(ifftshift(psikya));
qya   = ngrid2*ifft2(ifftshift(qkya));
qxa   = ngrid2*ifft2(ifftshift(qkxa));

% Get separate products on normal grid (real part) and shifted grid
% (imag part) in x-space

jg  = real(psixa).*real(qya) - real(psiya).*real(qxa);
jgs = imag(psixa).*imag(qya) - imag(psiya).*imag(qxa); 

% Take it back to k-space

Wk  = fftshift(fft2(jg + i*jgs))/ngrid2;

% Extract spectral products on grid and shifted grid, and average.

Wk_up = Wk(2:end,kmax+2:end);
Wk_dn = rot180(conj(Wk(2:end,2:kmax+2)));

jk = ((1 - i*conj(alphak)).*Wk_up + (1 + i*conj(alphak)).*Wk_dn)/4;
jk (1:kmax+1,1) = 0;