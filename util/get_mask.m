function damask = get_mask(kmax)

% damask = get_mask(kmax)
%    Create de-aliasing mask used in SQG model.  Produces 2D array
%    which conforms to spectral fields with max wavenumber kmax.
%    Isotropic truncation as per Orszag pseudo-spectral method.

k2 = get_ksqd(kmax);
damask = ones(2*kmax+1,kmax+1);

for i = 1:2*kmax+1
  for j = 1:kmax+1
    if (k2(i,j) >= (8./9.)*(kmax+1)^2),  damask(i,j) = 0.;, end
  end
end

damask(1:kmax+1,1) = 0.;
