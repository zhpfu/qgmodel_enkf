function [fout] = layerize(f,nx,ny,nz,frames)

% [fout] = LAYERIZE(f,nx,ny,nz,frames)  
%     Takes rank 2 array 'f', assumed to be a 4d integration field 
%     of size (nx,frames*nz*ny), with second dimension ordered by
%     (y,z,frames), and reshapes it into a rank 4 array of
%     size(nx,ny,nz,frames).
%
%     See also READ_FIELD.

fout = zeros(nx,ny,nz,frames);

for frm = 1:frames
   for layer = 1:nz
      lindi = ((frm-1)*nz+layer-1)*ny+1;
      uindi = ((frm-1)*nz+layer)*ny;
%      fout(:,1+(frm-1)*ny:frm*ny,layer) = f(:,lindi:uindi);
      fout(:,:,layer,frm) = f(:,lindi:uindi);
   end
end
fout = squeeze(fout);  % in case nz=1 or frames=1;