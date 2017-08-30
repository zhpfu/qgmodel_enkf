function [xc,yc] = centroid(f,x,y)

% [xc,yc] = CENTROID(f,x,y)  
%     Calculates centroid of 1d or 2d field 
%     f, where x is a vector containing corrdinate values for 
%     dimension 1 of f, and similarly for OPTIONAL y wrt dimension 2.

nx = size(f,1); ny = size(f,2);

if (length(x)~=nx) error('x is wrong length...'), end
if (ny>1)&(length(y)~=ny) error('y is wrong length..'), end
if (ny==1) y=1;, end

e = sum(sum(f));
xc = sum(x'.*sum(f,2))/e;
yc = sum(y.*sum(f,1))/e;