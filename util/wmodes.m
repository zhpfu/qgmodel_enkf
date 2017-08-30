function [kd,wmode,a,b,c] = wmodes(dz,rho,F);

% [kd,wmode,a,b,c] = WMODES(dz,rho,F)  
%
%     Calculates the vertical modes for the w equation, (1/N^2)w'' =
%     -(1/c^2)w.  Returns eigenvalues 1/c = kd (assuming nondim f=1),
%     and eigenectors w(level,mode), discretized so that w is defined
%     at z=0 (where it is 0), and at interfaces between density
%     layers.  Requires a density profile, rho(n), corresponding to
%     layers of thickness dz(n), and with F=f0^2 (L/(2*pi))^2/(g'*H0).
%     The eigenvectors (call them F_m(z) for the continuous form) are
%     normalized so that: Integral(F_m(z)*F_n(z)))dz =
%     Sum(del(z)*F_m(z)*F_n(z)) = delta_mn.
%
%     See also GET_W_PARAMS

dz = dz(:);  rho = rho(:);
dz = dz/sum(dz);
Dz = (dz(1:end-1) + dz(2:end))/2;  % distance between layer centers
nz = length(dz); 

[a,b,c] = get_w_params(dz,rho,F); % a,b and c have lenghts nz-1

A = diag(b,0)+diag(a(2:nz-1),-1)+diag(c(1:nz-2),1);

[V,D] = eig(A);

[kd,ri]=sort(sqrt(-diag(D)));
%kd(1)=0; 
wmode(:,:)=V(:,ri);

% Now normalize wmode so that <wmode_n,wmode_m> = delta_mn

for m=1:nz-1
   alpha=(wmode(:,m).*Dz'*wmode(:,m);
   wmode(:,m)=wmode(:,m)/sqrt(alpha);
   if (wmode(1,m)<0)
      wmode(:,m) = -wmode(:,m);
   end
end

