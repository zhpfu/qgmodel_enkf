module inflation

contains

function adapt_inflate_coef(yo,yb,varo) result(lambda)
  use mpi_util

  real :: lambda,vara,varb,varo,omb2
  real,dimension(:) :: yo
  real,dimension(:,:) :: yb
  integer :: nobs,nens,i,n

  nobs=size(yo)
  nens=size(yb,2)-1

  omb2=sum((yo-yb(:,nens+1))**2)/real(nobs) !omb-omb
  varb=sum(sum(yb(:,1:nens)**2,2)/real(nens-1))/real(nobs)

  lambda=sqrt(max(0.0,(omb2-varo)/varb))

  if(proc_id==0) print *,'var_b=',varb,' omb2-var_o=',omb2-varo
  if(proc_id==0) print *,'lambda=',lambda

end function adapt_inflate_coef

function adapt_relax_coef(yo,yb,ya,varo) result(alpha)
  use mpi_util

  real :: alpha,lambda,beta,vara,varb,varo,omb2,omaamb,amb2
  real,dimension(:) :: yo
  real,dimension(:,:) :: ya,yb
  integer :: nobs,nens,i,n

  nobs=size(yo)
  nens=size(yb,2)-1

  omaamb=sum((yo-ya(:,nens+1))*(ya(:,nens+1)-yb(:,nens+1)))/real(nobs) !oma-amb
  omb2=sum((yo-yb(:,nens+1))**2)/real(nobs) !omb-omb
  amb2=sum((ya(:,nens+1)-yb(:,nens+1))**2)/real(nobs)
  varb=sum(sum(yb(:,1:nens)**2,2)/real(nens-1))/real(nobs)
  vara=sum(sum(ya(:,1:nens)**2,2)/real(nens-1))/real(nobs)

  beta=sqrt(varb/vara)
  lambda=sqrt(max(0.0,(omb2-varo-amb2)/vara))
  !lambda=sqrt(omaamb/vara) !OMA-AMB statistics

  alpha=(lambda-1)/(beta-1)
  if(alpha>2) alpha=2 
  if(alpha<-1) alpha=-1
  if(beta<1) alpha=0

  if(proc_id==0) print *,'var_b=',varb,' var_a=',vara
  if(proc_id==0) print *,'omb2=',omb2,' amb2=',amb2
  if(proc_id==0) print *,'beta=',beta,' lambda=',lambda

end function adapt_relax_coef

end module inflation
