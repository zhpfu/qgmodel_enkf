function [ind] = sub2ind_(subarr,nmax);

%  [ind] = SUB2IND_(subarr,nmax)
%     Convert subscript, stored in array 'subarr', whose size is
%     equal to the rank of the array which it subscripts,
%     to single index.  Each subscript in subarr is assumed to lie
%     in the range [1:nmax].  Uses method employed in SQG model to 
%     store triple indexed spectral arrays.
%     
%     Example: (kmax=63, nz=5)
%
%     >> genms = read_field('genms',kmax,nz^3,1,10);
%     >> size(genms)
%
%     ans = 
%
%        63  125
%
%     >> plot(genms(:,sub2ind_([3 4 2],nz)))
%
%     The last command plots the (2 3 1) generation term, where
%     (2,3,1) is the subscript to the triple interaction coef.
%     (all indeces are offset by 1 since we can't have index<=0
%     with Matlab).  In particular, this term is
%     G(:,[2 3 1]) =
%     iso_spectra(-Um(3)*xi(2,3,1)*(lambda(3)^2-lambda(2)^2-K^2)*i*kx*
%     conj(psimk(:,:,1))*psikm(:,:,2))
%
%     See also IND2SUB_.

ind = 1 + sum( (subarr-1).*nmax.^(0:length(subarr)-1) );
