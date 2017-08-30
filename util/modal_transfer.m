function T = modal_transfer(psikm,qkm,e,mvec,file)

% T = MODAL_TRANSFER(psimk,qmk,e,mvec)  Calculate advective energy
%     flux into modes in 'mvec' as a function of kx,ky given spectral
%     modal projection fields qmk and psimk, and the triple inter-
%     action coef for the stratification used to generate fields.
%     dE_m/dt(kx,ky) = sum_jk(e_mjk*J(psi_m(kx,ky),psi_j(kx,ky))*
%     q_k(kx,ky)).  Returns T(kx,ky,mode).
%     NOTE:  jacobian used is NOT de-aliased so this won't be right...

nkx = size(psikm,1); nky = size(psikm,2); nz = size(psikm,3);

if nargin<4
   mvec=1:nz;
elseif (length(mvec)>nz | max(mvec)>nz)
   error ('Bad mvec')
end

T = zeros(nkx,nky,length(mvec));
total=length(find(abs(e(mvec,:,:))>100*eps));
cntr = 0;

for m = mvec
   for j=1:nz
      for k = 1:nz
         if abs(e(m,j,k))>100*eps 
            disp(strcat(num2str(cntr),...
              ' cycles of :',num2str(total),' completed'))
            jac_jk = jacobian(psikm(:,:,j),qkm(:,:,k));
            T(:,:,m) =T(:,:,m)+e(m,j,k)*real(conj(psikm(:,:,m)).*jac_jk);
            cntr=cntr+1;
         end
      end
   end
end

save T T   % Write result to T.mat in current directory