function isoplot(field,z,isovala,fcolora,...
      isovalb,fcolorb,aspect,smooth,camin,camax,amblight,cmap)

% ISOPLOT(field,z,isovala,fcolora,isovalb,fcolorb,aspect,...
%         smooth,camin,camax,amblight,cmap)
%     Iso-surface plot of 3d scalar field, whose vertical coordinate 
%     is z(:).  Color 'fcolora' for iso-value 'isovala', 
%     and similarly for second iso-value, 'isovalb'.  
%     Background uses SLICE to put values of field at bottom
%     and lateral boundaries, using 'shading interp'.
%
%     OPTIONAL    DEFAULT     FUNCTION
%     'aspect'    2           ratio of horizontal to vertical axes.  
%     'smooth'    0           1: SMOOTH3 input field (3 pt box filter).
%     'camin'     --          caxis min value for BG (requires camax).
%     'camax'     --          caxis max value for BG.
%     'amblight'  .6          lighting for boundaries.
%     'cmap'      gray        colormap for boundaries. 
%
%     Please alter this function to suit you.
%
%     See also VISSUITE, ISONORMALS, PATCH, SLICE.

% Defaults:
cmapd='gray'; amblightd=0.6; smoothd=0; aspectd=2; setcax=0;

% Optional
switch nargin
case 6, cmap=cmapd; amblight=amblightd; smooth=smoothd; 
   aspect=aspectd;
case 7, cmap=cmapd; amblight=amblightd; smooth=smoothd; 
case 8, cmap=cmapd; amblight=amblightd;
case 9, error('Need camax with camin');
case 10, cmap=cmapd; amblight=amblightd; setcax=1;
end
   
% Get coordinate limits and make grids
x = linspace(0,1,size(field,1));
y = linspace(0,1,size(field,2));
xmin = min(x); xmax = max(x);
ymin = min(y); ymax = max(y);
zmin = min(z); zmax = max(z);
[X,Y,Z] = meshgrid(x,y,z);

% Clear current figure window
clf

% Make boundary background from values of field at max x,y,z
colormap(cmap)
%hsurfaces = slice(X,Y,Z,field,[xmin xmax],ymax,zmin);
hsurfaces = slice(X,Y,Z,field,xmax,ymax,zmin);
set(hsurfaces,'FaceColor','interp','EdgeColor','none')

% Make patches and isosurfaces for isovala, color them fcolora
pa = patch(isosurface(X,Y,Z,field,isovala));
isonormals(X,Y,Z,field,pa);
set(pa, 'FaceColor', fcolora, 'EdgeColor', 'none');

% Similarly for isovalb
pb = patch(isosurface(X,Y,Z,field,isovalb));
isonormals(X,Y,Z,field,pb);
set(pb, 'FaceColor', fcolorb, 'EdgeColor', 'none');

daspect([1 1 aspect])   % aspect ratio: x and y equal, z=(x,y)/aspect 

view(3)                 % 3d view
camlight                % turn on the lights
lighting phong          % its pretty...
%set(hsurfaces,'AmbientStrength',amblight) % lighting of boundaries
camproj perspective     % perspective (other choice is 'orthographic')
axis off                % no tick marks or axis lines
axis tight              % fit to window
view(-10,10)            % (deg's from y axis, deg's azimuth)
zoom(1.2)
if (setcax==1)
   caxis manual
   caxis([camin camax]);
end
