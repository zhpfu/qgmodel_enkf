function [] = plotfield(field,layer,ptype,cmap,xvec,yvec,cvec)

% PLOTFIELD(field,layer,ptype,cmap,xvec,yvec,cvec) 
%     Plot 'layer' of 3d 'field' (assumes DIM 3 is
%     vertical, or layer coordinate index).  Plot type set 
%     by 'ptype',  with legal settings as follows:
%
%     'p'   -     PCOLOR with INTERP shading (default)
%     'pr'  -     PCOLOR with INTERP shading, set for printing
%     'pc'  -     PCOLOR with INTERP shading and COLORBAR
%     's'   -     SURF 
%     'c'   -     CONTOUR
%     'cf'  -     CONTOURF (filled contour)
%     'cfc' -     CONTOURF with COLORBAR
%       
%     Default layer is 1 and default colormap is cmap = 
%     system default ('hot'). Optional xvec and yvec are 
%     vectors containing coordinates for the axes in the plot.
%     Optional cvec sets color axis limits (2 comp't vector).
%     NOTE:  Axes for this function are sensible for data
%     (undoes the MATLAB default of matrix style plotting.)
%
%     See also PCOLOR, CONTOUR, CONTOURF, 

% Defaults

cvecd = 'auto'; yvecd = 1:size(field,2); xvecd = 1:size(field,1);
cmapd = 'hot'; ptyped = 'p'; layerd = 1;

switch nargin
   case 6, cvec = cvecd;
   case 5, cvec = cvecd; yvec = yvecd;
   case 4, cvec = cvecd; yvec = yvecd; xvec = xvecd;
   case 3, cvec = cvecd; yvec = yvecd; xvec = xvecd; cmap = cmapd;    
   case 2, cvec = cvecd; yvec = yvecd; xvec = xvecd; cmap = cmapd; 
           ptype = ptyped;
   case 1, cvec = cvecd; yvec = yvecd; xvec = xvecd; cmap = cmapd; 
           ptype = ptyped; layer = layerd; 
end

if ~isreal(field)
   field = real(field);
   disp('Plotting real part of this spectral field')
end
if cmap==0 cmap = cmapd;, end

switch layer
  case 0, field = squeeze(field)';
  otherwise, field = squeeze(field(:,:,layer))';
end

switch ptype
  case 'p',   colormap(cmap); pcolor(xvec,yvec,field); 
              shading interp; caxis(cvec);
  case 'pc',  colormap(cmap); pcolor(xvec,yvec,field); 
              shading interp; caxis(cvec); colorbar
  case 'pr',  colormap(cmap); pcolor(xvec,yvec,field);
	      shading interp; caxis(cvec);
	      set(get(gcf,'Children'),'YTick',[],'XTick',[]); % kill axes labels
              axis image;  % fix aspect ratio to that given by underlying data matrix
              set(gcf,'PaperPositionMode','auto');  % fix aspect ratio in printed plots
  case 's',   colormap(cmap); surf(xvec,yvec,field); caxis(cvec);
  case 'c',   contour(xvec,yvec,field)
  case 'cf',  colormap(cmap); contourf(xvec,yvec,field); caxis(cvec);
  case 'cfc', colormap(cmap); contourf(xvec,yvec,field); caxis(cvec); 
              colorbar
  otherwise, error('Invalid plot type')
end

axis image