program enkf

  use,intrinsic :: iso_c_binding
  use mpi_util
  use fft
  use scales
  use localization
  use relaxation
  use obs
  use grid

  implicit none

  integer :: nt,fin,iock
  integer :: m,n,p,s,i,j,k,nx,ny,nkx,nky,ns,nm,ie,v,w,nv
  character(256) :: arg,workdir,obsdir,nmlfile,infile,outfile,obfile

  real :: innov,varb,varo,norm,alpha
  complex,allocatable,dimension(:,:,:) :: uspec
  complex(C_DOUBLE_COMPLEX),allocatable,dimension(:,:) :: spec,hspec
  integer,allocatable,dimension(:,:) :: kx,ky
  integer,allocatable,dimension(:,:,:) :: x,y,z
  real,allocatable,dimension(:,:,:) :: um,umf,sig,sigf,dist,cova,loc
  real,allocatable,dimension(:,:,:,:) :: u,uf,um_ms,hum,humf,obs_val,hcova
  real,allocatable,dimension(:,:,:,:,:) :: u_ms,hu,huf,hum_ms
  real,allocatable,dimension(:,:,:,:,:,:) :: hu_ms

  integer :: kmax,nz,nens,localize_opt,ob_thin,find_roi,relax_opt
  real :: ob_err,relax_coef
  logical :: debug,relax_adapt
  integer,dimension(50) :: krange,localize_cutoff,ob_type
  integer,allocatable,dimension(:) :: kr,roi,obt

  namelist/enkf_param/kmax,nz,nens,localize_opt,localize_cutoff,krange,find_roi,&
                      ob_thin,ob_err,ob_type,relax_opt,relax_adapt,relax_coef,debug
  
  !initialize
  call parallel_start()

  call getarg(1,workdir)
  call getarg(2,obsdir)
  call getarg(3,arg)
  read(arg,*) nt

  nmlfile='param.in'
  open(unit=fin,file=nmlfile,iostat=iock)
  read(unit=fin,nml=enkf_param,iostat=iock)
  nkx=2*kmax+1
  nky=kmax+1
  nx=2*(kmax+1)
  ny=2*(kmax+1)

  call init_fft(kmax)

  ns=0
  do i=1,50
    if(krange(i)/=0) ns=ns+1
  end do
  allocate(kr(ns),roi(ns))
  kr=krange(1:ns)
  roi=localize_cutoff(1:ns)

  nv=0
  do v=1,50
    if(ob_type(v)/=0) nv=nv+1
  end do
  allocate(obt(nv))
  obt=ob_type(1:nv)

  nm=ceiling(real(nens)/nprocs)

  allocate(x(nx,ny,nz),y(nx,ny,nz),z(nx,ny,nz))
  allocate(dist(nx,ny,nz),loc(nx,ny,nz))
  allocate(cova(nx,ny,nz),hcova(nx,ny,nz,nv))
  allocate(uspec(nkx,nky,nz))
  allocate(spec(nx,ny),hspec(nkx,nky))
  allocate(kx(nkx,nky),ky(nkx,nky))
  allocate(u(nx,ny,nz,nm),uf(nx,ny,nz,nm),um(nx,ny,nz),umf(nx,ny,nz))
  allocate(hu(nx,ny,nz,nv,nm),huf(nx,ny,nz,nv,nm),hum(nx,ny,nz,nv),humf(nx,ny,nz,nv))
  allocate(sig(nx,ny,nz),sigf(nx,ny,nz))
  allocate(u_ms(nx,ny,nz,ns,nm),um_ms(nx,ny,nz,ns))
  allocate(hu_ms(nx,ny,nz,ns,nv,nm),hum_ms(nx,ny,nz,ns,nv))
  allocate(obs_val(nx,ny,nz,nv))

  call grid3d((/(i,i=1,nx)/),(/(i,i=1,ny)/),(/(i,i=1,nz)/),x,y,z)

  !read in priors and calculate mean
  u=0.0; um=0.0
  do m=1,nm
    ie=(m-1)*nprocs+proc_id+1
    if(ie<=nens) then
      write(infile,'(a,a,i4.4,a,i5.5,a)') trim(workdir),'/',ie,'/f_',nt,'.bin'
      call read_field(infile,nkx,nky,nz,uspec)
      do k=1,nz
        spec=fullspec(dcmplx(uspec(:,:,k)))
        spec=ifftshift(spec)
        u(:,:,k,m)=real(ifft2(spec))
      end do
    end if
  end do
  call MPI_Allreduce(sum(u,4),um,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
  um=um/real(nens)

  !read in observation and calculate obs prior
  write(obfile,'(a,a,i5.5)') trim(obsdir),'/',nt
  call get_obs(obfile)
  call grid2d((/(i,i=-kmax,kmax)/),(/(j,j=0,kmax)/),kx,ky)
  obs_val=-9999
  do v=1,nv
    do k=1,1  !observe top layer
    do j=1,ny,ob_thin
    do i=1,nx,ob_thin
      p=(k-1)*nx*ny+(j-1)*ny+i
      select case (obt(v)) !observation type
        case (1) !u
          obs_val(i,j,k,v)=obs_u(p)
        case (2) !v
          obs_val(i,j,k,v)=obs_v(p)
        case (3) !psi converted from uv
          obs_val(i,j,k,v)=obs_psi(p)
        case (4) !zeta converted from uv
          obs_val(i,j,k,v)=obs_zeta(p)
        case (5) !psi equiv gauss noise
          obs_val(i,j,k,v)=obs_psi1(p)
        case (6) !zeta equiv gauss noise
          obs_val(i,j,k,v)=obs_zeta1(p)
      end select
    end do
    end do
    end do

    hu=0.0; hum=0.0
    do m=1,nm
      ie=(m-1)*nprocs+proc_id+1
      if(ie<=nens) then
        do k=1,nz
          spec=dcmplx(u(:,:,k,m),0.0)
          spec=fft2(spec)/(nx*ny)
          spec=fftshift(spec)
          hspec=halfspec(spec)
          select case (obt(v))
          case (1) !u
            hspec=dcmplx(0.0,-ky)*hspec
          case (2) !v
            hspec=dcmplx(0.0,kx)*hspec
          case (4,6) !zeta
            hspec=-dcmplx(kx**2+ky**2,0.0)*hspec
          end select
          spec=fullspec(hspec)
          spec=ifftshift(spec)
          hu(:,:,k,v,m)=real(ifft2(spec))
        end do
      end if
    end do
    call MPI_Allreduce(sum(hu,5),hum,nx*ny*nz*nv,MPI_REAL8,MPI_SUM,comm,ierr)
    hum=hum/real(nens)
  end do  

  !ensemble perturbation
  do m=1,nm
    ie=(m-1)*nprocs+proc_id+1
    if(ie<=nens) then
      u(:,:,:,m)=u(:,:,:,m)-um
      hu(:,:,:,:,m)=hu(:,:,:,:,m)-hum
    end if
  end do
  uf=u; umf=um; huf=hu; humf=hum  !save prior values for statistics

  !adaptively find optimal roi
  if(localize_opt==2) then
    if(proc_id==0) print *,'adaptive localization:'
    if(find_roi==1) &
      call find_optimal_roi_mac(nens,u,kr,roi)
    if(find_roi==2) &
      call find_optimal_roi_chi(nens,u,kr,roi)
  end if


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !assimilation loop
  do k=1,1
  do j=1,ny,ob_thin
  do i=1,nx,ob_thin
    p=(k-1)*nx*ny+(j-1)*ny+i

    do v=1,nv !variable loop
      innov=obs_val(i,j,k,v)-hum(i,j,k,v)
      !if(abs(innov)>(1*ob_err)) then
        !if(proc_id==0) print *,'kick off'
        !cycle
      !end if

      varb=0.0
      call MPI_Allreduce(sum(hu(i,j,k,v,:)**2),varb,1,MPI_REAL8,MPI_SUM,comm,ierr)
      varb=varb/real(nens-1)

      varo=ob_err**2
      !varo=innov**2 !Huber norm or AOEI

      norm=varo+varb
      alpha=1.0/(1.0+sqrt(varo/norm))

      !distance between obs and x
      dist=sqrt((min(abs(x-obs_x(p)),abs(nx-x+obs_x(p))))**2 + &
                (min(abs(y-obs_y(p)),abs(ny-y+obs_y(p))))**2)
    
      !scale separation
      u_ms=0.0; um_ms=0.0; hu_ms=0.0; hum_ms=0.0;
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) then
          call separate_scales(u(:,:,:,m),kr,u_ms(:,:,:,:,m))
          do w=1,nv
            call separate_scales(hu(:,:,:,w,m),kr,hu_ms(:,:,:,:,w,m))
          end do
        end if
      end do
      call separate_scales(um,kr,um_ms)
      do w=1,nv
        call separate_scales(hum(:,:,:,w),kr,hum_ms(:,:,:,:,w))
      end do

      do s=1,ns
        loc=local_func(dist,roi(s),localize_opt)

        cova=0.0; hcova=0.0
        do m=1,nm
          ie=(m-1)*nprocs+proc_id+1
          if(ie<=nens) then
            where(loc>0) cova=cova+hu(i,j,k,v,m)*u_ms(:,:,:,s,m)
            do w=1,nv
              where(loc>0) hcova(:,:,:,w)=hcova(:,:,:,w)+hu(i,j,k,v,m)*hu_ms(:,:,:,s,w,m)
            end do
          end if
        end do
        call MPI_Allreduce(cova,cova,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
        cova=cova/real(nens-1)
        call MPI_Allreduce(hcova,hcova,nx*ny*nz*nv,MPI_REAL8,MPI_SUM,comm,ierr)
        hcova=hcova/real(nens-1)
  
        !update members
        do m=1,nm
          ie=(m-1)*nprocs+proc_id+1
          if(ie<=nens) then
            where(loc>0) u_ms(:,:,:,s,m)=u_ms(:,:,:,s,m)-alpha*loc*cova*hu(i,j,k,v,m)/norm
            do w=1,nv
              where(loc>0) hu_ms(:,:,:,s,w,m)=hu_ms(:,:,:,s,w,m)-alpha*loc*hcova(:,:,:,w)*hu(i,j,k,v,m)/norm
            end do
          end if
        end do
        !update mean
        where(loc>0) um_ms(:,:,:,s)=um_ms(:,:,:,s)+loc*cova*innov/norm
        do w=1,nv
          where(loc>0) hum_ms(:,:,:,s,w)=hum_ms(:,:,:,s,w)+loc*hcova(:,:,:,w)*innov/norm
        end do
      end do
  
      !sum all scales
      u=sum(u_ms,4); um=sum(um_ms,4)
      hu=sum(hu_ms,4); hum=sum(hum_ms,4)

      if(debug .and. proc_id==0) &
        write(*,'(a,i7,i3,a,f6.2,a,f6.2,a,f5.2,a,f7.2,f7.2)') 'No',p, obt(v), &
           ' (',obs_x(p),',',obs_y(p),',',obs_z(p),') ',obs_val(i,j,k,v),hum(i,j,k,v)

    end do !variable loop

  end do
  end do
  end do !assimilation loop
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


  !covariance relaxation and add mean back
  select case (relax_opt)
    case (0) !no relaxation
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          u(:,:,:,m)=u(:,:,:,m)+um
      end do

    case (1) !RTPP
      if(relax_adapt) relax_coef=adapt_rtpp_coef()
      if(proc_id==0) print *,'RTPP relax_coef = ',relax_coef
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          u(:,:,:,m)=relax_coef*uf(:,:,:,m)+(1-relax_coef)*u(:,:,:,m)+um
      end do

    case (2) !RTPS
      if(relax_adapt) relax_coef=adapt_rtps_coef()
      sigf=0.0
      sig=0.0
      call MPI_Allreduce(sum(uf**2,4),sigf,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
      call MPI_Allreduce(sum(u**2,4),sig,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
      sigf=sqrt(sigf/real(nens-1))
      sig=sqrt(sig/real(nens-1))
      if(proc_id==0) print *,'RTPS relax_coef = ',relax_coef
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          u(:,:,:,m)=(relax_coef*(sigf/sig-1)+1)*u(:,:,:,m)+um
      end do

  end select

  !write out posteriors
  do m=1,nm
    ie=(m-1)*nprocs+proc_id+1
    if(ie<=nens) then
      write(outfile,'(a,a,i4.4,a,i5.5,a)') trim(workdir),'/',ie,'/',nt,'.bin'
      do k=1,nz
        spec=dcmplx(u(:,:,k,m),0.0)
        spec=fft2(spec)/(nx*ny)
        spec=fftshift(spec)
        uspec(:,:,k)=cmplx(halfspec(spec))
      end do
      call write_field(outfile,nkx,nky,nz,uspec)
    end if
  end do

  deallocate(x,y,z,dist,loc,cova)
  deallocate(uspec,spec)
  deallocate(u,um,u_ms,um_ms,hu)

  if(proc_id==0) print*,'enkf complete'
  call parallel_finish()

end program enkf
