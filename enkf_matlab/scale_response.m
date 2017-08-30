function r = scale_response(k,krange,band)

nk=length(krange);

if(band<1 | band>nk)
  disp('band not within range!')
  exit
end

r=zeros(size(k));

center_k=krange(band);
if(band==1)
  r(k<=center_k)=1.0;
else
  left_k=krange(band-1);
  r(k<=center_k & k>=left_k) = cos( (k(k<=center_k & k>=left_k)-center_k).*(0.5*pi/(left_k-center_k)) ).^2;
end

if(band==nk)
  r(k>=center_k)=1.0;
else
  right_k=krange(band+1);
  r(k>=center_k & k<=right_k) = cos( (k(k>=center_k & k<=right_k)-center_k).*(0.5*pi/(right_k-center_k)) ).^2;
end

end
