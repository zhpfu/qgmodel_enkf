function eth = espec_th(k,r,g,C,kf);

%    eth = ESPEC_TH(k,r,g,C,kf)
%    
%    Theoretical universal energy spectrum
%    for 2D turbulence with linear drag.  k is a vector
%    containing wavenumbers over which to calculate 
%    spectrum, r is the linear drag coefficient, g is the
%    energy generation rate, assumed to be localized at the
%    wavenumber kf, and C is the Kolmogorov constant (C ~ 5.9).
%    If no kf is entered, it will be assumed infinite.

if (nargin == 5) 
   eth = C*g^(2/3)*k.^(-5/3).*(1+C*r*g^(-1/3)*(kf^(-2/3)-k.^(-2/3))).^2 ...
      .*(k>(C*r*g^(-1/2))^(3/2));
else
   eth = C*g^(2/3)*k.^(-5/3).*(1-C*r*g^(-1/3)*k.^(-2/3)).^2 ...
      .*(k>(C*r*g^(-1/2))^(3/2));
end
