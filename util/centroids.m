function kc = centroids(f,k)

% kc = CENTROIDS(f,k)  
%     Calculates time-series of centroids of spectra f = f(k,t) 
%     where k is a vector containing corrdinate values for 
%     dimension 1 of f.  Returns kc = kc(t).

nk = size(f,1); nt = size(f,2);

if (length(k)~=nk) error('k is wrong length...'), end

for n=1:nt;
  kc(n) = sum(k(:).*f(:,n))/sum(f(:,n));
end
