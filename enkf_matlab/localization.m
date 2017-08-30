function loc=localization(dist,cutoff)
r=dist./(cutoff/2);
loc=zeros(size(r));
loc1=((((r./12 - 0.5).* r +0.625).*r +5/3).*r -5).*r +4-2./(3.*r);
loc2=(((-0.25.*r +0.5).*r +0.625).*r -5/3).*r.^2+1;

ind1=(dist>=cutoff/2 & dist<cutoff);
ind2=(dist<cutoff/2);
loc(ind1)=loc1(ind1);
loc(ind2)=loc2(ind2);
