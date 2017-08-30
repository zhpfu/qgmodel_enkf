function ps = smooth_spec(w,p,smth)
n=length(p);
for m=1:length(w)
  ind=max(1,floor(m/smth)):min(ceil(m*smth),n);
  ps(m)=mean(p(ind));
end
