
subroutine read_field(filename,nx,ny,nz,field)
  implicit none
  character(len=*), intent(in) :: filename
  integer, intent(in) :: nx,ny,nz
  complex,dimension(nx,ny,nz),intent(out) :: field
  real,dimension(nx,ny,nz) :: fr,fi
  integer :: fid,iock,recunit=8,i,j,k
  open(unit=fid,file=filename,form='unformatted',access='direct',recl=recunit*nx,iostat=iock)
  do k=1,nz
  do j=1,ny
    read(fid,rec=(k-1)*ny+j,iostat=iock) (fr(i,j,k),i=1,nx)
    read(fid,rec=(k-1)*ny+j+ny*nz,iostat=iock) (fi(i,j,k),i=1,nx)
  end do
  end do
  close(fid)
  field=cmplx(fr,fi)
end subroutine read_field

subroutine write_field(filename,nx,ny,nz,field)
  implicit none
  character(len=*), intent(in) :: filename
  integer, intent(in) :: nx,ny,nz
  complex,dimension(nx,ny,nz),intent(in) :: field
  real,dimension(nx,ny,nz) :: fr,fi
  integer :: fid,iock,recunit=8,i,j,k
  fr=real(field)
  fi=aimag(field)
  open(unit=fid,file=filename,form='unformatted',access='direct',recl=recunit*nx,iostat=iock)
  do k=1,nz
  do j=1,ny
    write(fid,rec=(k-1)*ny+j,iostat=iock) (fr(i,j,k),i=1,nx)
    write(fid,rec=(k-1)*ny+j+ny*nz,iostat=iock) (fi(i,j,k),i=1,nx)
  end do
  end do
  close(fid)
end subroutine write_field

