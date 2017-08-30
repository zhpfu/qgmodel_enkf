function [w sprd]=sprdspec(ens)

[nx ny nz nm nt]=size(ens);
ensmean=mean(ens,4);
for m=1:nm
  [w p(:,m,:)]=pwrspec2d(squeeze(ens(:,:,:,m,:)-ensmean));
end

sprd=sum(p,2)./(nm-1);
