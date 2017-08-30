module localization

contains

function local_func(dist,roi,localize_opt) result(loc)
  real,dimension(:,:,:) :: dist
  integer :: localize_opt
  real,dimension(size(dist,1),size(dist,2),size(dist,3)) :: r,loc
  integer :: roi
  real :: r1,r2
  if(localize_opt.eq.0) then
    loc=1.0
  else
    r1=real(roi)
    r2=real(roi)/2
    r=dist/r2
    loc=0.0
    where(dist>=r2 .and. dist<r1) &
      loc=((((r/12 - 0.5)*r +0.625)*r +5.0/3)*r -5)*r +4-2.0/(3*r)
    where(dist<r2) &
      loc=(((-0.25*r +0.5)*r +0.625)*r-5.0/3)*(r**2)+1
  end if
end function local_func


subroutine find_optimal_roi_chi(nens,u,krange,roi)

  use mpi_util
  use stats
  use scales

  implicit none
  integer,intent(in) :: nens
  real,dimension(:,:,:,:),intent(in) :: u
  integer,dimension(:),intent(in) :: krange
  integer,dimension(:),intent(out) :: roi

  real,dimension(:,:,:,:,:),allocatable :: ums
  real,dimension(:,:),allocatable :: cova,varb,ub,rc,rcsamp
  integer :: nx,ny,nz,nm,ns,i,j,k,m,s,l,n,nb
  real :: varo,uo,x,y,chi2max,chi2rc
  real,dimension(:),allocatable :: bins,exsamp

  if(proc_id==0) print *,'finding optimal roi using chi-square test'
  k=2 !vertical level
  nb=200
  allocate(bins(nb+1))
  bins=(/(i,i=-nb/2,nb/2)/)/real(nb/2)
  chi2max=chi2inv(0.99,nb-1)

  nx=size(u,1)
  ny=size(u,2)
  nz=size(u,3)
  nm=size(u,4)
  ns=size(krange)
  allocate(ums(nx,ny,nz,ns,nm))
  allocate(ub(nx,ny),varb(nx,ny),cova(nx,ny),rc(nx,ny))
  allocate(rcsamp(2*nx*ny,nx/2))
  allocate(exsamp(2*nx*ny))

  !monte carlo draw of expected zero-correlation sample
  exsamp=drawn_sample_corr(nens,2*nx*ny)

  !scale separation
  ums=0.0
  do m=1,nm
    if( ((m-1)*nprocs+proc_id+1)<=nens ) &
      call separate_scales(u(:,:,:,m),krange,ums(:,:,:,:,m))
  end do

  do s=1,ns
    if(proc_id==0) print *,'scale',s
    n=0
    do i=1,nx
    do j=1,ny
      n=n+1
      !calculate correlation map
      cova=0.0
      varo=0.0
      varb=0.0
      do m=1,nm
        ub=ums(mod((/(n,n=i-1,i+nx-2)/),nx)+1,mod((/(n,n=j-1,j+ny-2)/),ny)+1,k,s,m)
        uo=u(i,j,k,m)
        cova=cova+ub*uo
        varb=varb+ub**2
        varo=varo+uo**2
      end do
      call MPI_Allreduce(cova,cova,nx*ny,MPI_REAL8,MPI_SUM,comm,ierr)
      call MPI_Allreduce(varb,varb,nx*ny,MPI_REAL8,MPI_SUM,comm,ierr)
      call MPI_Allreduce(varo,varo,1,MPI_REAL8,MPI_SUM,comm,ierr)
      rc=cova/sqrt(varo*varb)
      !pick 2 rc samples at each dist, and gather them
      rcsamp(n,:)=rc(2:nx/2+1,1)
      rcsamp(nx*ny+n,:)=rc(1,2:nx/2+1)
    end do
    end do
    !find optimal roi with chi2 test
    roi(s)=0
    do l=1,nx/2
      chi2rc=chi2(rcsamp(:,l),exsamp,bins)
      !if(proc_id==0) print*,chi2rc,chi2max
      if( chi2rc<chi2max ) exit
      roi(s)=l
    end do
  end do

  if(proc_id==0) then
     print *, '    k=',krange
     print *, '  roi=',roi
  end if
end subroutine find_optimal_roi_chi


subroutine find_optimal_roi_mac(nens,u,v,krange,roi)

  use mpi_util
  use stats
  use scales
  use grid

  implicit none
  integer,intent(in) :: nens
  real,dimension(:,:,:,:),intent(in) :: u,v
  integer,dimension(:),intent(in) :: krange
  integer,dimension(:),intent(out) :: roi

  real,dimension(:,:,:,:,:),allocatable :: ums
  real,dimension(:,:),allocatable :: cova,varb,dist,mask,ub,mac
  real,dimension(:,:),allocatable :: x,y
  real,dimension(:),allocatable :: dsc
  integer,dimension(:),allocatable :: no
  integer :: nx,ny,nz,nm,ns,i,j,k,m,s,l,n
  real :: macl,macex,varo,uo,nol

  if(proc_id==0) print *,'finding optimal roi using mean abs correlation'
  nx=size(u,1)
  ny=size(u,2)
  nz=size(u,3)
  nm=size(u,4)
  ns=size(krange)
  allocate(ums(nx,ny,nz,ns,nm))
  allocate(x(nx,ny),y(nx,ny),ub(nx,ny),dist(nx,ny))
  allocate(mask(nx,ny),varb(nx,ny),cova(nx,ny),mac(nx,ny))

  !expected mean abs corr
  if(proc_id==0) then
    allocate(dsc(nx*ny))
    dsc=drawn_sample_corr(nens,nx*ny)
    macex=sqrt(sum((dsc-sum(dsc)/real(nx*ny))**2)/real(nx*ny-1))
  end if
  call MPI_bcast(macex,1,MPI_REAL8,0,comm,ierr)
!print *,proc_id,macex

  !scale separation
  ums=0.0
  do m=1,nm
    if( ((m-1)*nprocs+proc_id+1)<=nens ) &
      call separate_scales(u(:,:,:,m),krange,ums(:,:,:,:,m))
  end do

  k=1 !vertical level

  call grid2d(real((/(i,i=1,nx)/)),real((/(i,i=1,ny)/)),x,y)
  dist=sqrt(real((min(abs(x-1),abs(nx-x+1)))**2 + (min(abs(y-1),abs(ny-y+1)))**2))
  do s=1,ns
    if(proc_id==0) print *,'scale',s
    mac=0.0
    do i=1,nx
    do j=1,ny
      !calculate correlation map
      cova=0.0
      varo=0.0
      varb=0.0
      do m=1,nm
        ub=ums(mod((/(n,n=i-1,i+nx-2)/),nx)+1,mod((/(n,n=j-1,j+ny-2)/),ny)+1,k,s,m)
        uo=v(i,j,k,m)
        cova=cova+ub*uo
        varb=varb+ub**2
        varo=varo+uo**2
      end do
      call MPI_Allreduce(cova,cova,nx*ny,MPI_REAL8,MPI_SUM,comm,ierr)
      call MPI_Allreduce(varb,varb,nx*ny,MPI_REAL8,MPI_SUM,comm,ierr)
      call MPI_Allreduce(varo,varo,1,MPI_REAL8,MPI_SUM,comm,ierr)
      mac=mac+abs(cova/sqrt(varo*varb))
    end do
    end do
    mac=mac/real(nx*ny)
    !find optimal roi based on mean abs corr
    roi(s)=0
    do l=1,nx/2
      mask=0.0
      where(dist>=l .and. dist<(l+1)) mask=1.0
      macl=sum(mask*mac)/sum(mask)
      if(macl<macex) exit
      roi(s)=l
    end do
  end do

  if(proc_id==0) then
     print *, '    k=',krange
     print *, '  roi=',roi
  end if
end subroutine find_optimal_roi_mac

end module localization
