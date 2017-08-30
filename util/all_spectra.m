function [] = all_spectra(dirnmvec,groupname,frmvec,kmax,nz,specnmvec,itype,...
   ftype,dtype);

% ALL_SPECTRA(dirnmvec,groupname,frmvec,kmax,nz,specnmvec,itype,ftype,dtype)
%     Calculate averages for 2d spectra whose names are given in
%     the optional cell string array 'specnmvec', from all spectra
%     in the directories given in the cell string array 'dirnmvec'.
%     Collect frames given by 'frmvec' (presumably in the equilibrated
%     range) and make average spectrum.  Store all of same type
%     of spectra in cat(specname,groupname), which will then 
%     have 3 dimensions (the third dimension will denote which 
%     directory it came from).
%
%     EXAMPLE:
%     >> ls
%     T05 T07 T09 
%     >> dirnmvec = {'T05' 'T07' 'T09'};
%     >> all_spectra(dirnmvec,'Ta',1001:10:3000,{'kes' 'gens'});
%     >> who
%     Your variables are:
%     
%     kesTa     gensTa    dirnamesTa
%
%     >> size(kesTa_av)
%     ans = 
%
%        31  2  3
%     
%     >> loglog(kesTa_av(:,:,3))
%
%     So, the last command is the log-log plot of the averaged (over
%     frames 1001:10:3000) of the kinetic energy
%     spectra for the two layers (length of second dimension = 2 layers)
%     of the run in directory T09 (kmax for these runs is 31).
%
%     Optional 'itype', 'ftype' and 'dtype' are integer, file and real 
%     data types.
%     
%     DEFAULTS:  specnmvec = {'kems', 'apems', 'genms', 'bdms',
%                             'hvdms', 'xferms'}
%                itype = 'bit64', ftype = 's'
%
%     See also READ_FIELD, FOPEN.

% Defaults:

specnmvecd = {'kems' 'apems' 'genms' 'bdms' 'hvdms' 'xferms'};
ityped = 'bit64';  ftyped = 's'; dtyped = 'real*8';

switch nargin
   case 1, error('Too few arguments')
   case 2, error('Too few arguments')
   case 3, error('Too few arguments')
   case 4, error('Too few arguments')
   case 5, dtype = dtyped; ftype = ftyped; itype = ityped; 
      specnmvec = specnmvecd; 
   case 6, dtype = dtyped; ftype = ftyped; itype = ityped; 
   case 7, dtype = dtyped; ftype = ftyped;
end

if (~iscellstr(dirnmvec)), error('dirnmvec must be a cell array')
end
if (~iscellstr(specnmvec)), error('specnmvec must be a cell array')
end

numspecs = length(specnmvec);
numdirs = length(dirnmvec);
numfrms = length(frmvec);

for m = 1:numspecs
  name = char(strcat(specnmvec(m),groupname));
  display(name);
  for n = 1:numdirs
    dirname = char(dirnmvec(n));
%    [kmax,nz] = getparams_ac(dirname,0,itype,ftype);
    specname = char(strcat(dirnmvec(n),'/',specnmvec(m)))
    spec = read_field(specname,kmax,nz,1,frmvec,ftype);
    if (nz>1) 
      specav(:,:,n) = sum(spec,3)/numfrms;
    else
      specav(:,n) = sum(spec,2)/numfrms;
    end
  end
  assignin('base',name,specav);
end
rootdir = pwd;
dirnames = strcat(rootdir,'/',dirnmvec);
assignin('base',strcat('dirnames_',groupname),dirnames);
