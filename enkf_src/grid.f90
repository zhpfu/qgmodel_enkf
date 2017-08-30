module grid

contains

subroutine grid2d(xind,yind,x,y)
  real,dimension(:),intent(in) :: xind,yind
  real,dimension(size(xind),size(yind)),intent(out) :: x,y
  integer :: i,j,nx,ny
  nx=size(xind)
  ny=size(yind)
  y=spread(yind,1,nx)
  x=spread(xind,2,ny)
end subroutine grid2d

subroutine grid3d(xind,yind,zind,x,y,z)
  real,dimension(:),intent(in) :: xind,yind,zind
  real,dimension(size(xind),size(yind),size(zind)),intent(out) :: x,y,z
  integer :: i,j,k,nx,ny,nz
  nx=size(xind)
  ny=size(yind)
  nz=size(zind)
  x=spread(spread(xind,2,ny),3,nz)
  y=spread(spread(yind,1,nx),3,nz)
  z=spread(spread(zind,1,nx),2,ny)
end subroutine grid3d

!function interp2(x,y,u,xo,yo) result(r)
!end function interp2

end module grid
