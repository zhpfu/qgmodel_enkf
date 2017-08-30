function rho = mac(nens,count)

rng('shuffle');
ctrue=[1 0; 0 1]; mtrue=[0 0];
for i=1:count
  s=mvnrnd(mtrue,ctrue,nens);
  rho(i)=corr(s(:,1),s(:,2));
end
