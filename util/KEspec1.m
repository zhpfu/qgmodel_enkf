function [w p]=KEspec1(psik)

[uk vk]=psi2uv(psik);
u=spec2grid(uk); v=spec2grid(vk);
[w pu]=pwrspec2d(u);
[w pv]=pwrspec2d(v);
p=0.5*(pu+pv);
