function [kd,evec,a,b,c] = vmodes(dz,rho,F);

% [kd,evec] = VMODES(dz,rho,F)  
%
%     Calculates the deformation wavenmbers
%     for a density profile, rho(n), corresponding to layers of thickness
%     dz(n), and with F=f0^2 (L/(2*pi))^2/(g'*H0).  Also gives the matrix
%     of eigenvectors (the vertical modes), organized as evec(level,mode).
%     These eigenvectors (call them F_m(z) for the continuous form) 
%     are normalized so that:
%     Integral(F_m(z)*F_n(z)))dz = Sum(del(z)*F_m(z)*F_n(z)) = delta_mn.
%
%     See also GET_STRAT_PARAMS

dz = dz(:);  rho = rho(:);
nz = length(dz);

[a,b,c] = get_strat_params(dz,rho,F);

A = diag(b,0)+diag(a(2:nz),-1)+diag(c(1:nz-1),1);

[V,D] = eig(A);

[kd,ri]=sort(sqrt(-diag(D)));
kd(1)=0; 
evec(:,:)=V(:,ri);

% Now normalize evec so that <evec_n,evec_m> = delta_mn

dz=dz/sum(dz);
for m=1:nz
   alpha=(evec(:,m).*dz)'*evec(:,m);
   evec(:,m)=evec(:,m)/sqrt(alpha);
   if (evec(1,m)<0)
      evec(:,m) = -evec(:,m);
   end
end

