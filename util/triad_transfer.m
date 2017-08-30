function [sigma,kx_Aa,ky_Aa,eg_bnd,sigmaA,sigmaC] = ...
  triad_transfer(e_,kz,mA,mB,mC,kx_B,nk);

% [sigma,kx_Aa,ky_Aa,eg_bnd,sigmaA,sigmaC] 
%                     = TRIAD_TRANSFER(e_,kz,mA,mB,mC,kx_B,nk)    
%     Intermode growth rate, sigma, as per Fu & Flierl, 1980 
%     (Dyn. Atmos. Oc., 4, 219--246).  In particular, this gives 
%     transfer rate for wave (kx_A,ky_A) as a function of (kx_B,ky_B),
%     but we assume WOLOG that ky_B = 0, and specify only kx_B.
%     e_ is the 3d array of tripple interaction coefficients, 
%     (mA,mB,mC) is the mode triplet being considered, and kz is an 
%     array of deformation wavenumbers (get e_ and kz as output from 
%     TRIPINTCOEF.M).  A,B,C are the subscripts for the triplet,
%     such that K_A < K_B < K_C, where K^2 = kx^2 + ky^2 + kz_m^2, 
%     m is the mode number.  Output is sigma, a 2d array defined on 
%     (kx_A,ky_A) space with resolution of nk.  eg_bnd is array 
%     of size(sigma) which is one where dE_A/dt > dE_C/dt, and 0
%     otherwise.  sigmaA = (dE_A/dt)/E_0, sigmaC = (dE_C/dt)/E_0,
%     just as sigma = sigmaB = (dE_B/dt)/E_0, so that
%     sigmaA+sigmaB+sigmaC=0.
%
%     See also TRIPINTCOEF, TRIADGR.

if mod(nk,2)==0, 
   warning('I suggest using ODD nk instead for zero-centered grid')
end

e_ABC = e_(mA+1,mB+1,mC+1);
kz_A = kz(mA+1); kz_B = kz(mB+1); kz_C = kz(mC+1);

Rmax = sqrt(kx_B^2 + kz_B^2 - kz_A^2);

kx_Aa = linspace(-Rmax,Rmax,nk);
ky_Aa = linspace(-Rmax,Rmax,nk);
[kx_A,ky_A] = meshgrid(kx_Aa,ky_Aa);

a = 2*kx_A*kx_B + kx_A.^2 + ky_A.^2 + kz_C^2 - kz_B^2;
b = kx_B^2 - kx_A.^2 - ky_A.^2 + kz_B^2 - kz_A^2;
c = kx_B^2 + kx_A.^2 + 2*kx_A*kx_B + ky_A.^2 + kz_A^2 + kz_C^2;
d = kx_A.^2 + ky_A.^2 + kz_A^2;
e = kx_B^2 + 2*kx_A*kx_B + kz_C^2 - kz_A^2;

quotient = (a>0).*(b>0).*a.*b./(c.*d);

% This is essentially eqn (11) from FF80, but with constraints 

sigma = -.5*abs(e_ABC)*abs(ky_A/kx_B).*sqrt(quotient);
sigmaA = -sigma.*a./e;
sigmaC = -sigma.*b./e; % WRONG -- want this as a f'n of kx_C

% Now find area in which d/dt(E_A)>d/dt(E_C), assuming all energy 
% starts in mode B (so that E_A, E_B >= 0).
% It turns out that d/dt(E_A) = (a/b) * d/dt(E_C), so we
% need to know where a = b.

eg_bnd = ((a-b)>eps);