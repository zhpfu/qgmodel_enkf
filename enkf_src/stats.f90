module stats
contains

 function ran() result(r)
   real :: r
   call random_seed()
   call random_number(r)
 end function ran

 function ran3(idum)
      INTEGER idum
      INTEGER MBIG,MSEED,MZ
!     REAL MBIG,MSEED,MZ
      REAL ran3,FAC
      PARAMETER (MBIG=1000000000,MSEED=161803398,MZ=0,FAC=1./MBIG)
!     PARAMETER (MBIG=4000000.,MSEED=1618033.,MZ=0.,FAC=1./MBIG)
      INTEGER i,iff,ii,inext,inextp,k
      INTEGER mj,mk,ma(55)
!     REAL mj,mk,ma(55)
      SAVE iff,inext,inextp,ma
      DATA iff /0/
      if(idum.lt.0.or.iff.eq.0)then
        iff=1
        mj=MSEED-iabs(idum)
        mj=mod(mj,MBIG)
        ma(55)=mj
        mk=1
        do 11 i=1,54
          ii=mod(21*i,55)
          ma(ii)=mk
          mk=mj-mk
          if(mk.lt.MZ)mk=mk+MBIG
          mj=ma(ii)
11      continue
        do 13 k=1,4
          do 12 i=1,55
            ma(i)=ma(i)-ma(1+mod(i+30,55))
            if(ma(i).lt.MZ)ma(i)=ma(i)+MBIG
12        continue
13      continue
        inext=0
        inextp=31
        idum=1
      endif
      inext=inext+1
      if(inext.eq.56)inext=1
      inextp=inextp+1
      if(inextp.eq.56)inextp=1
      mj=ma(inext)-ma(inextp)
      if(mj.lt.MZ)mj=mj+MBIG
      ma(inext)=mj
      ran3=mj*FAC
      return
 end function ran3

 function gaussdev(idum)
      integer idum
      real gaussdev
      integer iset
      real fac,gset,rsq,v1,v2,ran1
      save iset, gset
      data iset/0/
      if (iset.eq.0) then
 10      v1 = 2.*ran3(idum)-1.
         v2 = 2.*ran3(idum)-1.
         rsq = v1**2 + v2**2
         if (rsq.ge.1. .or. rsq.eq.0.) goto 10
         fac = sqrt( -2.*log(rsq)/rsq )
         gset = v1*fac
         gaussdev = v2*fac
         iset= 1
      else
         gaussdev = gset
         iset=0
      end if
      return
 end function gaussdev

 function randn(idum,n) result(r)
   integer :: idum,n,i
   real, dimension(n) :: r
   do i=1,n
     r(i)=gaussdev(idum+i)
   end do
 end function randn

 function corr(s1,s2) result(r)
   real,dimension(:) :: s1,s2
   real :: r,m1,m2,cova,var1,var2
   integer :: n,i
   n=size(s1)
   r=0.0
   m1=sum(s1)/real(n)
   m2=sum(s2)/real(n)
   cova=sum((s1-m1)*(s2-m2))
   var1=sum((s1-m1)**2)
   var2=sum((s2-m2)**2)
   r=cova/sqrt(var1*var2)
 end function

 function drawn_sample_corr(nens,nobs) result(r)
    integer :: nens,nobs,i,j,idum
    real :: rdum
    real,dimension(nobs) :: r
    real,dimension(nens) :: s1,s2
    call random_seed()
    do j=1,nobs
      call random_number(rdum)
      idum=int(nobs*rdum)
      do i=1,nens
        s1(i)=gaussdev(idum+i)
        s2(i)=gaussdev(idum+i+nens)
      end do
      r(j)=corr(s1,s2)
    end do
 end function drawn_sample_corr

 !function ksdensity(dat,bins) result(r)
   !real,dimension(:) :: dat
   !real,dimension(:) :: bins
   !real,dimension(size(bins,1)) :: r
   !integer :: n,nd
   !n=size(bins)
   !nd=size(dat)
   
 !end function ksdensity

 function chi2(so,se,bins) result(x)
   real,dimension(:) :: se,so,bins
   real :: x,ce,co
   integer :: n,ns,i,nzero
   ns=size(se)
   n=size(bins)
   x=0.0
   nzero=0
   do i=1,n-1
     co=size(pack(so,(so>=bins(i) .and. so<bins(i+1))))
     ce=size(pack(se,(se>=bins(i) .and. se<bins(i+1))))
!print *,co,ce,(co-ce)**2/max(1.0,co+ce)
     if(ce==0) then 
       nzero=nzero+1
       cycle
     end if
     x=x+(co-ce)**2/(ce+co)
   end do
 end function chi2

 function chi2inv(p,v) result(x)
   real :: p,x
   integer :: v,stat
   double precision :: pd,xd,vd,bound
   pd=dble(p)
   vd=dble(v)
   call cdfchi(2,pd,1-pd,xd,vd,stat,bound)
   x=real(xd)
 end function

end module stats
