function v = findzeros(f,x)

% v = FINDZEROS(f,x)  
%     Returns a vector containing the best approximation 
%     of the zeros of the 1-d vector f.  Optional argument x is the f
%     same size asis assumed to contain the values of the independent 
%     variable of which f is a function.  Uses simple linear interpolation, 
%     so this is intended for high resolution functions.

nv = length(f);

if nargin==2
   if nv~=length(x)
      error('Both input arguments must be of the same length')
   end
elseif nargin==1
   x=1:nv;
else
   error('Must have one or two arguments')
end

numzs=0;
for n=2:nv
   if sign(f(n))~=sign(f(n-1)) 
      numzs=numzs+1;
      s(numzs)=n;
   end
end

for j=1:numzs
   n = s(j);
   m = (f(n)-f(n-1))/(x(n)-x(n-1));    % local slope
   v(j) = -f(n-1)/m + x(n-1);
end
