module obs

real,dimension(:),allocatable :: obs_x,obs_y,obs_z,obs_u,obs_v,obs_zeta,obs_psi,obs_temp
integer :: nrec

contains

subroutine get_obs(obfile)
  character(len=*),intent(in) :: obfile
  integer :: fin,iock,p
  real,dimension(7) :: dat

  open(unit=fin,file=obfile,form='formatted',iostat=iock)
  nrec=0
  do
    read(fin,*,iostat=iock) dat
    if(iock/=0) then
      if(iock>0) print *,'obs file read error!'
      exit
    else
      nrec=nrec+1
    end if
  end do
  close(fin)

  allocate(obs_x(nrec))
  allocate(obs_y(nrec))
  allocate(obs_z(nrec))
  allocate(obs_u(nrec))
  allocate(obs_v(nrec))
  allocate(obs_zeta(nrec))
  allocate(obs_psi(nrec))
  allocate(obs_temp(nrec))

  open(unit=fin,file=obfile,form='formatted',iostat=iock)
  do p=1,nrec
    read(fin,*) obs_x(p),obs_y(p),obs_z(p),obs_u(p),obs_v(p),obs_psi(p),obs_zeta(p),obs_temp(p)
!!obs thin here
  end do

  close(fin)
end subroutine get_obs

subroutine obs_interp(x,y,z,u,obs_x,obs_y,obs_z,hu)
  real,dimension(:,:,:) :: x,y,z
  real,dimension(:,:,:) :: u
  real :: hu, obs_x,obs_y,obs_z, dx,dxm,dy,dym,dz,dzm
  integer :: nx,ny,nz, x1,y1,z1
  nx=size(u,1)
  ny=size(u,2)
  nz=size(u,3)

  hu=u(int(obs_x),int(obs_y),int(obs_z))
  !!linear interpolation
  !x1=floor(obs_x); y1=floor(obs_y); z1=floor(obs_z)
  !x2=ceiling(obs_x); y2=ceiling(obs_y); z2=ceiling(obs_z)
  !dx1=obs_x-real(x1)
  !dx2=real(x2)-obs_x
  !dy1=obs_y-real(y1)
  !dy2=real(y2)-obs_y
  !dz1=obs_z-real(z1)
  !dz2=real(z2)-obs_z
  !hu=(1-dz1-dz2)*((1-dy1-dy2)*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1)) &
                         !+dy1*((1-dx1-dx2)*u(x1,y2,z1)+dx1*u(x2,y2,z1)+dx2*u(x1,y2,z1)) &
                         !+dy2*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1))) &
            !+dz1*((1-dy1-dy2)*((1-dx1-dx2)*u(x1,y1,z2)+dx1*u(x2,y1,z2)+dx2*u(x1,y1,z2)) &
                         !+dy1*((1-dx1-dx2)*u(x1,y2,z2)+dx1*u(x2,y2,z2)+dx2*u(x1,y2,z2)) &
                         !+dy2*((1-dx1-dx2)*u(x1,y1,z2)+dx1*u(x2,y1,z2)+dx2*u(x1,y1,z2))) &
            !+dz2*((1-dy1-dy2)*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1)) &
                         !+dy1*((1-dx1-dx2)*u(x1,y2,z1)+dx1*u(x2,y2,z1)+dx2*u(x1,y2,z1)) &
                         !+dy2*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1)))

end subroutine obs_interp

end module obs
