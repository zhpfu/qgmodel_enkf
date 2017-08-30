function [gr,k] = triadgr(e_,kz,mB,kxB,nk)

% gr = TRIADGR(e_,kz,mAvec,mBvec,mCvec,kxBvec,nk)  
%     Calculates max growth rate for all kx_B in kxBvec and for
%     all modes specified by all combinations of modes specified
%     in mAvec, mBvec and mCvec.  
%
%     See also TRIAD_TRANSFER.

% !add error checking!

Kmax = sqrt(kxB^2 + kz(mB+1)^2);
k_master = linspace(0,Kmax,nk);
gr = zeros(nk,length(kz));

for mA = mAvec
   for mB = mBvec
      for mC = mCvec
         if e_(mA+1,mB+1,mC+1)>100*eps          % Only do non-0 calcs
            [mA, mB, mC, e_(mA+1,mB+1,mC+1)]    % display
            kcntr = 0;
            kcntr = kcntr+1;
            [sigma,kx,ky,eb,sigmaA,sigmaC] = ...
               triad_transfer(e_,kz,mA,mB,mC,kxB,nk);
            [sigisoA,k] = iso_max(sigmaA,kx,ky);
            [sigisoC,k] = iso_max(sigmaC,kx,ky);               
         end
      end
   end
end
