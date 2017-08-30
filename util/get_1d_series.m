function [series] = get_1d_series(file,nx,ny,frmvec);

%  SERIES = GET_1D_SERIES(file,nx,ny,frmvec)
%     Reads in frames (size nx by ny) in frmvec of series of 
%     2d spectra in file (call it 'spec'),  and sets, for each n
%     in frmvec, series(:,n) = sum(spec,1).  The purpose is to 
%     get a 1d timeseries from a sequence of 2d spectra - for
%     example, getting the timeseries of energy in the barotropic
%     mode from a sequence of modal energy spectra (2d fns of 
%     K and mode).
%
%     See also READ_FIELD.

n = 0;
for frm = frmvec
n = n+1;
   spec = read_field(file,nx,ny,1,frm);
   series(n,:) = sum(spec,1);
end
