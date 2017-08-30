function [subarr] = ind2sub_(ind,nmax,nsub);

%  [subarr] = IND2SUB_(ind,nmax,nsub)  
%     Convert linear index 'ind' to subscript.  Output is array
%     of subscripts - size of this array is equal to 'nsub', the 
%     rank of array which it subscripts.  Each subscript has a 
%     range [1,nmax].  
%
%     Argument 'nsub' is optional - default is 3.
%
%     This is the inverse operation of the function
%     SUB2IND_, which uses the same method employed in SQG model
%     to store triple indexed spectral arrays.
%
%     See also SUB2IND_.

if (nargin<3) nsub = 3;,  end

indm1 = ind - 1;  % Move range from [0,nmax^3-1] to [1,nmax^3]
for j = 1:nsub
   subarr(j) = 1 + (mod(indm1,nmax^j)-mod(indm1,nmax^(j-1)))/nmax^(j-1);
end
