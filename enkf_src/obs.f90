module obs

real,dimension(:),allocatable :: obs_x,obs_y,obs_z,obs_u,obs_v,&
                                 obs_zeta,obs_psi,obs_temp
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
    read(fin,*) obs_x(p),obs_y(p),obs_z(p), obs_u(p),obs_v(p), &
                obs_psi(p),obs_zeta(p),obs_temp(p)
  end do
  close(fin)
end subroutine get_obs

subroutine obs_interp(x,y,z,u,obs_x,obs_y,obs_z,hu)
  real,dimension(:,:,:) :: x,y,z
  real,dimension(:,:,:) :: u
  real :: hu, obs_x,obs_y,obs_z
  integer :: nx,ny,nz
  nx=size(u,1)
  ny=size(u,2)
  nz=size(u,3)

  hu=u(int(obs_x),int(obs_y),int(obs_z))
  !no interpolation yet

end subroutine obs_interp

end module obs
