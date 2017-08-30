function [kmax,nz] = getparams(datadir,inbase,itype,ftype);

% [kmax,nz] = GETPARAMS(datadir,inbase,itype,ftype)
%
%     Reads in 'parameters.bin' for SQG model output in directory
%     'datadir'.  If nz>1, this also reads in mean state profiles,
%     dz, rho, ubar, vmode and kz.  Also makes isotropic k axis for
%     plotting spectral quantities.  
%
%     Optional arguments: 'itype' sets integer type 
%     (default is 'ieee-be.le32'), 
%     'ftype' sets binar file type (default is 'ieee-be.l64'), 
%     inbase: 1 => write all values to workspace (default is 1).
%     The current defaults are appropriate for reading from
%     model when run on LSC/AC machines at GFDL.
%
%     See also FOPEN, FREAD.

%Defaults:
paramfile = '/parameters.bin';
ftyped = 'n'; ityped = 'int32'; rtyped = 'float64'; inbased = 1;

switch nargin
  case 0, ftype = ftyped; itype = ityped; inbase = inbased; datadir='.';
  case 1, ftype = ftyped; itype = ityped; inbase = inbased; 
  case 2, ftype = ftyped; itype = ityped; 
  case 3, ftype = ftyped;
end
rtype = rtyped;

fname=strcat(datadir,paramfile);
[fid,msg] = fopen(fname,'r',ftype);
if fid<0 disp(fname), error(msg), end

kmax = fread(fid,[1 1],itype);
nz = fread(fid,[1 1],itype);
F = fread(fid,[1 1],rtype);
beta = fread(fid,[1 1],rtype);
bot_drag = fread(fid,[1 1],rtype);
uscale = fread(fid,[1 1],rtype);
d1frame = fread(fid,[1 1],itype);
d2frame = fread(fid,[1 1],itype);
frame = fread(fid,[1 1],itype);
fclose(fid);

nkx = 2*kmax+1;  nky = kmax+1;
nx = 2*(kmax+1); ny = nx;

if (nz>1) 
   dz   = read_field(strcat(datadir,'/dz'),1,1,1,1,ftype);
   rho  = read_field(strcat(datadir,'/rho'),1,1,1,1,ftype);
   ubar = read_field(strcat(datadir,'/ubar'),1,1,1,1,ftype);
   %vbar = read_field(strcat(datadir,'/vbar'),1,1,1,1,ftype);
   vbar = [0 0]';
   kz   = read_field(strcat(datadir,'/kz'),1,1,1,1,ftype);
   vmode= read_field(strcat(datadir,'/vmode'),nz,nz,1,1,ftype);
   dz = dz(:); rho = rho(:); ubar = ubar(:); vbar = vbar(:); kz = kz(:);
   z = get_z(dz);
   zi = -cumsum(dz(1:nz-1));
   um = (dz.*ubar)'*vmode;
   vm = (dz.*vbar)'*vmode;
end

k = 1:kmax;
m = 0:nz-1;

% If no return variables are specified, assign all variables
% calcualated and read here in either workspace or caller.

if (nargout==0)   
  if inbase==1 
    WS='base';
  else
    WS='caller';
  end

  assignin(WS,'kmax',kmax);
  assignin(WS,'nz',nz);
  assignin(WS,'nkx',nkx);
  assignin(WS,'nky',nky);
  assignin(WS,'nx',nx);
  assignin(WS,'ny',ny);
  assignin(WS,'F',F);
  assignin(WS,'beta',beta);
  assignin(WS,'bot_drag',bot_drag);
  if (nz>1)
    assignin(WS,'dz',dz);
    assignin(WS,'rho',rho);
    assignin(WS,'ubar',ubar);
    assignin(WS,'vbar',vbar);
    assignin(WS,'um',um);
    assignin(WS,'vm',vm);
    assignin(WS,'kz',kz);
    assignin(WS,'vmode',vmode);
    assignin(WS,'z',z);
    assignin(WS,'zi',zi);
  end
  assignin(WS,'k',k);
  assignin(WS,'m',m);
  assignin(WS,'datadir',datadir);
  assignin(WS,'d1frame',d1frame)
  assignin(WS,'d2frame',d2frame)
  assignin(WS,'frame',frame);

end
