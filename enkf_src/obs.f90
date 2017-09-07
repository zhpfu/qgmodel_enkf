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

  !hu=u(int(obs_x),int(obs_y),int(obs_z))
  !linear interpolation
  x1=floor(obs_x); y1=floor(obs_y); z1=floor(obs_z)
  x2=ceiling(obs_x); y2=ceiling(obs_y); z2=ceiling(obs_z)
  dx1=obs_x-real(x1)
  dx2=real(x2)-obs_x
  dy1=obs_y-real(y1)
  dy2=real(y2)-obs_y
  dz1=obs_z-real(z1)
  dz2=real(z2)-obs_z
  hu=(1-dz1-dz2)*((1-dy1-dy2)*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1)) &
                         +dy1*((1-dx1-dx2)*u(x1,y2,z1)+dx1*u(x2,y2,z1)+dx2*u(x1,y2,z1)) &
                         +dy2*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1))) &
            +dz1*((1-dy1-dy2)*((1-dx1-dx2)*u(x1,y1,z2)+dx1*u(x2,y1,z2)+dx2*u(x1,y1,z2)) &
                         +dy1*((1-dx1-dx2)*u(x1,y2,z2)+dx1*u(x2,y2,z2)+dx2*u(x1,y2,z2)) &
                         +dy2*((1-dx1-dx2)*u(x1,y1,z2)+dx1*u(x2,y1,z2)+dx2*u(x1,y1,z2))) &
            +dz2*((1-dy1-dy2)*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1)) &
                         +dy1*((1-dx1-dx2)*u(x1,y2,z1)+dx1*u(x2,y2,z1)+dx2*u(x1,y2,z1)) &
                         +dy2*((1-dx1-dx2)*u(x1,y1,z1)+dx1*u(x2,y1,z1)+dx2*u(x1,y1,z1)))

end subroutine obs_interp



SUBROUTINE quicksort(n,x,ind)
 
IMPLICIT NONE

REAL, INTENT(IN)  :: x(n)
INTEGER, INTENT(IN OUT)   :: ind(n)
INTEGER, INTENT(IN)    :: n

!***************************************************************************

!                                                         ROBERT RENKA
!                                                 OAK RIDGE NATL. LAB.

!   THIS SUBROUTINE USES AN ORDER N*LOG(N) QUICK SORT TO SORT A REAL 
! ARRAY X INTO INCREASING ORDER.  THE ALGORITHM IS AS FOLLOWS.  IND IS
! INITIALIZED TO THE ORDERED SEQUENCE OF INDICES 1,...,N, AND ALL INTERCHANGES
! ARE APPLIED TO IND.  X IS DIVIDED INTO TWO PORTIONS BY PICKING A CENTRAL
! ELEMENT T.  THE FIRST AND LAST ELEMENTS ARE COMPARED WITH T, AND
! INTERCHANGES ARE APPLIED AS NECESSARY SO THAT THE THREE VALUES ARE IN
! ASCENDING ORDER.  INTERCHANGES ARE THEN APPLIED SO THAT ALL ELEMENTS
! GREATER THAN T ARE IN THE UPPER PORTION OF THE ARRAY AND ALL ELEMENTS
! LESS THAN T ARE IN THE LOWER PORTION.  THE UPPER AND LOWER INDICES OF ONE
! OF THE PORTIONS ARE SAVED IN LOCAL ARRAYS, AND THE PROCESS IS REPEATED
! ITERATIVELY ON THE OTHER PORTION.  WHEN A PORTION IS COMPLETELY SORTED,
! THE PROCESS BEGINS AGAIN BY RETRIEVING THE INDICES BOUNDING ANOTHER
! UNSORTED PORTION.

! INPUT PARAMETERS -   N - LENGTH OF THE ARRAY X.

!                      X - VECTOR OF LENGTH N TO BE SORTED.

!                    IND - VECTOR OF LENGTH >= N.

! N AND X ARE NOT ALTERED BY THIS ROUTINE.

! OUTPUT PARAMETER - IND - SEQUENCE OF INDICES 1,...,N PERMUTED IN THE SAME
!                          FASHION AS X WOULD BE.  THUS, THE ORDERING ON
!                          X IS DEFINED BY Y(I) = X(IND(I)).

!*********************************************************************

! NOTE -- IU AND IL MUST BE DIMENSIONED >= LOG(N) WHERE LOG HAS BASE 2.
! (OK for N up to about a billon)

!*********************************************************************

INTEGER   :: iu(21), il(21)
INTEGER   :: m, i, j, k, l, ij, it, itt, indx
REAL      :: r
REAL      :: t

! LOCAL PARAMETERS -

! IU,IL =  TEMPORARY STORAGE FOR THE UPPER AND LOWER
!            INDICES OF PORTIONS OF THE ARRAY X
! M =      INDEX FOR IU AND IL
! I,J =    LOWER AND UPPER INDICES OF A PORTION OF X
! K,L =    INDICES IN THE RANGE I,...,J
! IJ =     RANDOMLY CHOSEN INDEX BETWEEN I AND J
! IT,ITT = TEMPORARY STORAGE FOR INTERCHANGES IN IND
! INDX =   TEMPORARY INDEX FOR X
! R =      PSEUDO RANDOM NUMBER FOR GENERATING IJ
! T =      CENTRAL ELEMENT OF X

IF (n <= 0) RETURN

! INITIALIZE IND, M, I, J, AND R

DO  i = 1, n
  ind(i) = i
END DO
m = 1
i = 1
j = n
r = .375

! TOP OF LOOP

20 IF (i >= j) GO TO 70
IF (r <= .5898437) THEN
  r = r + .0390625
ELSE
  r = r - .21875
END IF

! INITIALIZE K

30 k = i

! SELECT A CENTRAL ELEMENT OF X AND SAVE IT IN T

ij = i + r*(j-i)
it = ind(ij)
t = x(it)

! IF THE FIRST ELEMENT OF THE ARRAY IS GREATER THAN T,
!   INTERCHANGE IT WITH T

indx = ind(i)
IF (x(indx) > t) THEN
  ind(ij) = indx
  ind(i) = it
  it = indx
  t = x(it)
END IF

! INITIALIZE L

l = j

! IF THE LAST ELEMENT OF THE ARRAY IS LESS THAN T,
!   INTERCHANGE IT WITH T

indx = ind(j)
IF (x(indx) >= t) GO TO 50
ind(ij) = indx
ind(j) = it
it = indx
t = x(it)

! IF THE FIRST ELEMENT OF THE ARRAY IS GREATER THAN T,
!   INTERCHANGE IT WITH T

indx = ind(i)
IF (x(indx) <= t) GO TO 50
ind(ij) = indx
ind(i) = it
it = indx
t = x(it)
GO TO 50

! INTERCHANGE ELEMENTS K AND L

40 itt = ind(l)
ind(l) = ind(k)
ind(k) = itt

! FIND AN ELEMENT IN THE UPPER PART OF THE ARRAY WHICH IS
!   NOT LARGER THAN T

50 l = l - 1
indx = ind(l)
IF (x(indx) > t) GO TO 50

! FIND AN ELEMENT IN THE LOWER PART OF THE ARRAY WHCIH IS NOT SMALLER THAN T

60 k = k + 1
indx = ind(k)
IF (x(indx) < t) GO TO 60

! IF K <= L, INTERCHANGE ELEMENTS K AND L

IF (k <= l) GO TO 40

! SAVE THE UPPER AND LOWER SUBSCRIPTS OF THE PORTION OF THE
!   ARRAY YET TO BE SORTED

IF (l-i > j-k) THEN
  il(m) = i
  iu(m) = l
  i = k
  m = m + 1
  GO TO 80
END IF

il(m) = k
iu(m) = j
j = l
m = m + 1
GO TO 80

! BEGIN AGAIN ON ANOTHER UNSORTED PORTION OF THE ARRAY

70 m = m - 1
IF (m == 0) RETURN
i = il(m)
j = iu(m)

80 IF (j-i >= 11) GO TO 30
IF (i == 1) GO TO 20
i = i - 1

! SORT ELEMENTS I+1,...,J.  NOTE THAT 1 <= I < J AND J-I < 11.

90 i = i + 1
IF (i == j) GO TO 70
indx = ind(i+1)
t = x(indx)
it = indx
indx = ind(i)
IF (x(indx) <= t) GO TO 90
k = i

100 ind(k+1) = ind(k)
k = k - 1
indx = ind(k)
IF (t < x(indx)) GO TO 100

ind(k+1) = it
GO TO 90
END SUBROUTINE quicksort




end module obs
