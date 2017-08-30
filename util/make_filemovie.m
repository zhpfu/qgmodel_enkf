function movie_out=make_filemovie(file,nx,ny,nz,frmvec,CV,...
   ptype,cmap,ftype);

% [movie_out] = MAKE_FILEMOVIE(file,nx,ny,nz,frmvec,layer,CV,
%                             ftype,ptype,cmap)
%     Make movie of 'layer' of frames in 'frmvec' of 'file' 
%     using PLOTFIELD.  File is of type ftype (default 's').
%     Axis fixed with V (default 'auto').
%     
%     See also PLOTFIELD, READ_FIELD, FOPEN, FREAD, MOVIEIN,
%     MAKE_MOVIE.

% Defaults:
cmapd = 'hot'; ptyped = 'p'; ftyped ='s'; CVd='auto'; layerd=1;
zoff = 0;
movie_out = moviein(length(frmvec));

switch nargin
  case 5, cmap = cmapd; ptype = ptyped; ftype = ftyped; CV = CVd; 
   layer = layerd;
  case 6, cmap = cmapd; ptype = ptyped; ftype = ftyped; CV = CVd;
  case 7, cmap = cmapd; ptype = ptyped; ftype = ftyped;
  case 8, cmap = cmapd; ptype = ptyped;   
  case 9, cmap = cmapd;
end
if CV==0 CV=CVd;, end
if cmap==0 cmap=cmapd;, end

n=0;
clf; 
lyr = 1;
for frm=frmvec
   disp(frm)
   f = read_field(file,nx,ny,nz,frm,ftype);
   f = get_vorticity(f);
   fg = spec2grid(f);
   clf
   plotfield(fg,1)
%   pcolor(fg); shading interp;
%   caxis(CV);
   n=n+1;
   pause
   movie_out(:,n) = getframe;
end
