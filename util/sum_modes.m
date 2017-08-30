function [fs] = sum_modes(f,nz)

% fs = SUM_MODES(f,nz)
%     For a triple indexed modal function (i.e.
%     generation or internal transfer spectra),
%     sum over triplets to get just forcing of
%     or transfer to/from each mode.  Assumes 
%     second index of f is arranged in the way
%     SUB2IND_ converts multiple index to single
%     index.  nz is number of modes/layers.  
%     Result is sum over second and third indeces.
%
%     See also SUB2IND_, MODAL_TRANSFER.

kmax = size(f,1);  
fs = zeros(kmax,nz);

for i = 1:nz
   for j = 1:nz
      for m = 1:nz
         fs(:,m) = fs(:,m) + f(:,sub2ind_([i,j,m],nz));
      end
   end
end
