function [pfield,kespec] = modes_in_layer(fieldm,layer,vmode,mvec)

% [pfield,kespec] = MODES_IN_LAYER(fieldm,layer,vmode,mvec)
%     Returns modal projections onto 'layer' of 3d field.  Input 
%     field is assumed MODAL in 3rd dimension, and either spectral
%     or physical in horizontal (1st and 2nd) dimensions.  Output will 
%     have same horizontal structure, and 3rd dimension will contain 
%     the projection fields of modes in 'mvec' (optional - all modes
%     are computed if this is not specified) onto layer.  
%     e.g.  If we want to know how much of surface signal is barotropic
%     and how much is first baroclinic, 
%
%     psi(z=0) := psi^{n=1} = Sum_m [Psi_m phi_m^{n=1}]
%                           = Psi_0 phi_0^1 + Psi_1 phi_1^1 + ...
%                             -------------   -------------
%                             BT proj'n ^^    BC1 proj'n ^^
%
%     Optionally, IF INPUT FIELD IS SPECTRAL STREAMFUNCTION, then
%     function can return KE spectra (kespec) of each projection.
%     Function checks that field is spectral, but has no way of
%     knowing that field is a streamfunction and not, say, PV...
%
%     See also MODE2LAYER, LAYER2MODE, VMODES, FULLSPEC.


nx = size(fieldm,1);  ny = size(fieldm,2);  nz = size(fieldm,3);

if size(vmode) ~= [nz nz]
   error('Wrong sized vmode array')
end
if nargin<4
   mvec = 1:nz;
end
for m = mvec
   pfield(:,:,m) = fieldm(:,:,m)*vmode(layer,m);
end

if nargout>1
   if (nx+1~=ny*2), error('These are not spectral fields'), end
   kmax = ny-1;
   ksqd = get_ksqd(kmax);
   for m = mvec
      KE(:,:,m) = ksqd.*real(pfield(:,:,m).*conj(pfield(:,:,m)));
   end
   kespec = iso_spectra(KE);
end







