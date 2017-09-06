program enkf

  use,intrinsic :: iso_c_binding
  use mpi_util
  use fft
  use scales
  use localization
  use inflation
  use obs
  use grid

  implicit none

  integer :: nt,fin,iock
  integer :: m,n,p,r,s,i,j,k,k1,nx,ny,nkx,nky,ns,nm,ie,v,nv,nobs
  character(256) :: arg,workdir,obsdir,nmlfile,infile,outfile,obfile

  real :: innov,varb,varo,norm,alpha
  complex,allocatable,dimension(:,:,:) :: uspec
  complex(C_DOUBLE_COMPLEX),allocatable,dimension(:,:) :: spec,hspec
  real,allocatable,dimension(:,:) :: kx,ky
  real,allocatable,dimension(:,:,:) :: x,y,z
  real,allocatable,dimension(:) :: hu,yo,obsv
  real,allocatable,dimension(:,:) :: ya,yb
  real,allocatable,dimension(:,:,:) :: um,umf,sig,sigf,dist,cova,loc
  real,allocatable,dimension(:,:,:,:) :: u,uf,uobs,um_ms
  real,allocatable,dimension(:,:,:,:,:) :: u_ms

  integer :: kmax,nz,nens,localize_opt,ob_thin,find_roi,relax_opt,state_type
  real :: ob_err,obs_val,relax_coef,inflate_coef
  logical :: debug,relax_adapt,inflate_adapt,use_aoei
  integer,dimension(50) :: krange,localize_cutoff,ob_type
  integer,allocatable,dimension(:) :: kr,roi,obt

  namelist/enkf_param/kmax,nz,nens,localize_opt,localize_cutoff,krange,find_roi,&
                      ob_thin,ob_err,ob_type,state_type, &
                      inflate_adapt,inflate_coef,use_aoei, &
                      relax_opt,relax_adapt,relax_coef,debug
  
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
  allocate(kx(nkx,nky),ky(nkx,nky))
  allocate(dist(nx,ny,nz),loc(nx,ny,nz))
  allocate(cova(nx,ny,nz))
  allocate(uspec(nkx,nky,nz))
  allocate(spec(nx,ny),hspec(nkx,nky))
  allocate(u(nx,ny,nz,nm),um(nx,ny,nz))
  allocate(uf(nx,ny,nz,nm),umf(nx,ny,nz))
  allocate(sig(nx,ny,nz),sigf(nx,ny,nz))
  allocate(uobs(nx,ny,nz,nm))
  allocate(u_ms(nx,ny,nz,ns,nm),um_ms(nx,ny,nz,ns))
  allocate(hu(nens+1))

  call grid3d(real((/(i,i=1,nx)/)),real((/(i,i=1,ny)/)),real((/(i,i=1,nz)/)),x,y,z)

  call grid2d(real((/(i,i=-kmax,kmax)/)),real((/(j,j=0,kmax)/)),kx,ky)
  !where(kx==0) kx=1
  !where(ky==0) ky=1

  !read in observation file
  write(obfile,'(a,a,i5.5)') trim(obsdir),'/',nt
  call get_obs(obfile)

  !read in priors and calculate mean
  u=0.0; um=0.0
  do m=1,nm
    ie=(m-1)*nprocs+proc_id+1
    if(ie<=nens) then
      write(infile,'(a,a,i4.4,a,i5.5,a)') trim(workdir),'/',ie,'/f_',nt,'.bin'
      call read_field(infile,nkx,nky,nz,uspec)
      do k=1,nz
        hspec=dcmplx(uspec(:,:,k))
        !select case (state_type) !convert psi to state variable
          !case (1) !u
            !hspec=hspec*dcmplx(0.0,-ky)
          !case (2) !v
            !hspec=hspec*dcmplx(0.0,kx)
          !case (4) !zeta
            !hspec=hspec*dcmplx(-(kx**2+ky**2),0.0)
          !case (5) !temp
            !hspec=hspec*dcmplx(-sqrt(kx**2+ky**2),0.0)
        !end select
        spec=fullspec(hspec)
        spec=ifftshift(spec)
        u(:,:,k,m)=real(ifft2(spec))
      end do
    end if
  end do
  call MPI_Allreduce(sum(u,4),um,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
  um=um/real(nens)

  !ensemble perturbation
  do m=1,nm
    ie=(m-1)*nprocs+proc_id+1
    if(ie<=nens) &
      u(:,:,:,m)=u(:,:,:,m)-um
  end do
  uf=u; umf=um !prior perturbation and mean

  nobs=nrec*nv

  !prior statistics in obs space
  allocate(obsv(nrec),yo(nobs),ya(nobs,nens+1),yb(nobs,nens+1))
  n=0
  do v=1,nv
    select case (obt(v))
      case (1) !u
        obsv=obs_u
      case (2) !v
        obsv=obs_v
      case (3) !psi 
        obsv=obs_psi
      case (4) !zeta 
        obsv=obs_zeta
      case (5) !temp
        obsv=obs_temp
    end select
    do m=1,nm
      ie=(m-1)*nprocs+proc_id+1
      if(ie<=nens) then
        uobs(:,:,:,m)=uf(:,:,:,m)+umf
        do k=1,nz
          spec=dcmplx(uobs(:,:,k,m),0.0)
          spec=fft2(spec)/(nx*ny)
          spec=fftshift(spec)
          hspec=halfspec(spec)
          !select case (state_type)
            !case (1) !u
              !hspec=hspec/dcmplx(0.0,-ky)
            !case (2) !v
              !hspec=hspec/dcmplx(0.0,kx)
            !case (4) !zeta
              !hspec=hspec/dcmplx(-(kx**2+ky**2),0.0)
            !case (5) !temp
              !hspec=hspec/dcmplx(-sqrt(kx**2+ky**2),0.0)
          !end select
          select case (obt(v))
            case (1)
              hspec=hspec*dcmplx(0.0,-ky)
            case (2)
              hspec=hspec*dcmplx(0.0,kx)
            case (4)
              hspec=hspec*dcmplx(-(kx**2+ky**2),0.0)
            case (5)
              hspec=hspec*dcmplx(-sqrt(kx**2+ky**2),0.0)
          end select
          spec=fullspec(hspec)
          spec=ifftshift(spec)
          uobs(:,:,k,m)=real(ifft2(spec))
        end do
      end if
    end do

    do p=1,nrec
      n=n+1
      yo(n)=obsv(p)
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          call obs_interp(x,y,z,uobs(:,:,:,m),obs_x(p),obs_y(p),obs_z(p),yb(n,ie))
      end do
    end do
  end do
  call MPI_Allreduce(yb,yb,nobs*(nens+1),MPI_REAL8,MPI_SUM,comm,ierr)
  yb(:,nens+1)=sum(yb(:,1:nens),2)/real(nens)
  do m=1,nens
    yb(:,m)=yb(:,m)-yb(:,nens+1)
  end do

  !inflation
  if(inflate_adapt) inflate_coef=adapt_inflate_coef(yo,yb,ob_err**2)
  u=u*inflate_coef

  !adaptively find optimal roi
  if(localize_opt==2) then
    if(proc_id==0) print *,'adaptive localization:'
    if(find_roi==1) &
      call find_optimal_roi_mac(nens,u,u,kr,roi)
    if(find_roi==2) &
      call find_optimal_roi_chi(nens,u,kr,roi)
  end if

  !assimilation loop
  do p=1,nrec

    do v=1,nv !variable loop

      select case (obt(v))
        case (1)
          obs_val=obs_u(p) !u
        case (2) 
          obs_val=obs_v(p) !v
        case (3) 
          obs_val=obs_psi(p) !psi
        case (4) 
          obs_val=obs_zeta(p) !zeta
        case (5) 
          obs_val=obs_temp(p) !temp
      end select

      !observation prior
      hu=0.0
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) then
          uobs(:,:,:,m)=u(:,:,:,m)+um
          do k1=1,1  !no interp in vertical
            spec=dcmplx(uobs(:,:,k1,m),0.0)
            spec=fft2(spec)/(nx*ny)
            spec=fftshift(spec)
            hspec=halfspec(spec)
            !select case (state_type)
              !case (1) !u
                !hspec=hspec/dcmplx(0.0,-ky)
              !case (2) !v
                !hspec=hspec/dcmplx(0.0,kx)
              !case (4) !zeta
                !hspec=hspec/dcmplx(-(kx**2+ky**2),0.0)
              !case (5) !temp
                !hspec=hspec/dcmplx(-sqrt(kx**2+ky**2),0.0)
            !end select
            select case (obt(v))
              case (1)
                 hspec=hspec*dcmplx(0.0,-ky)
              case (2)
                 hspec=hspec*dcmplx(0.0,kx)
              case (4)
                hspec=hspec*dcmplx(-(kx**2+ky**2),0.0)
              case (5)
                hspec=hspec*dcmplx(-sqrt(kx**2+ky**2),0.0)
            end select
            spec=fullspec(hspec)
            spec=ifftshift(spec)
            uobs(:,:,k1,m)=real(ifft2(spec))
          end do
          call obs_interp(x,y,z,uobs(:,:,:,m),obs_x(p),obs_y(p),obs_z(p),hu(ie))
        end if
      end do
      call MPI_Allreduce(hu,hu,nens+1,MPI_REAL8,MPI_SUM,comm,ierr)
      hu(nens+1)=sum(hu(1:nens))/real(nens)
      do m=1,nens
        hu(m)=hu(m)-hu(nens+1)
      end do

      innov=obs_val-hu(nens+1)
      if(abs(innov)>(5*ob_err)) then
        if(proc_id==0) print *,'kick off'
        cycle
      end if

      varb=sum(hu(1:nens)**2)/real(nens-1)
      varo=ob_err**2
      if(use_aoei) varo=innov**2 !Huber norm or AOEI
      norm=varo+varb
      alpha=1.0/(1.0+sqrt(varo/norm))

      !distance between obs and x, accouting for period bc
      dist=sqrt((min(abs(x-obs_x(p)),nx-abs(x-obs_x(p))))**2 + &
                (min(abs(y-obs_y(p)),ny-abs(y-obs_y(p))))**2)
    
      !scale separation
      u_ms=0.0
      um_ms=0.0
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          call separate_scales(u(:,:,:,m),kr,u_ms(:,:,:,:,m))
      end do
      call separate_scales(um,kr,um_ms)

      do s=1,ns
        cova=0.0
        do m=1,nm
          ie=(m-1)*nprocs+proc_id+1
          if(ie<=nens) then
            where(loc>0) &
              cova=cova+hu(ie)*u_ms(:,:,:,s,m)
          end if
        end do
        call MPI_Allreduce(cova,cova,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
        cova=cova/real(nens-1)
  
        loc=local_func(dist,roi(s),localize_opt) !localization function

        !update members
        do m=1,nm
          ie=(m-1)*nprocs+proc_id+1
          if(ie<=nens) then
            where(loc>0) &
              u_ms(:,:,:,s,m)=u_ms(:,:,:,s,m)-alpha*loc*cova*hu(ie)/norm
          end if
        end do
        !update mean
        where(loc>0) &
          um_ms(:,:,:,s)=um_ms(:,:,:,s)+loc*cova*innov/norm
      end do
  
      !sum all scales
      u=sum(u_ms,4)
      um=sum(um_ms,4)

      if(debug .and. proc_id==0) &
        write(*,'(a,i8,i3,a,f6.2,a,f6.2,a,f5.2,a,f7.2,f7.2)') 'No',p, obt(v), &
           ' (',obs_x(p),',',obs_y(p),',',obs_z(p),') ',obs_val,hu(nens+1)

    end do !variable loop

  end do !assimilation loop

  !posterior statistics in obs space
  n=0
  do v=1,nv
    do m=1,nm
      ie=(m-1)*nprocs+proc_id+1
      if(ie<=nens) then
        uobs(:,:,:,m)=u(:,:,:,m)+um
        do k=1,nz
          spec=dcmplx(uobs(:,:,k,m),0.0)
          spec=fft2(spec)/(nx*ny)
          spec=fftshift(spec)
          hspec=halfspec(spec)
          !select case (state_type)
            !case (1) !u
              !hspec=hspec/dcmplx(0.0,-ky)
            !case (2) !v
              !hspec=hspec/dcmplx(0.0,kx)
            !case (4) !zeta
              !hspec=hspec/dcmplx(-(kx**2+ky**2),0.0)
            !case (5) !temp
              !hspec=hspec/dcmplx(-sqrt(kx**2+ky**2),0.0)
          !end select
          select case (obt(v))
            case (1)
              hspec=hspec*dcmplx(0.0,-ky)
            case (2)
              hspec=hspec*dcmplx(0.0,kx)
            case (4)
              hspec=hspec*dcmplx(-(kx**2+ky**2),0.0)
            case (5)
              hspec=hspec*dcmplx(-sqrt(kx**2+ky**2),0.0)
          end select
          spec=fullspec(hspec)
          spec=ifftshift(spec)
          uobs(:,:,k,m)=real(ifft2(spec))
        end do
      end if
    end do

    do p=1,nrec
      n=n+1
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          call obs_interp(x,y,z,uobs(:,:,:,m),obs_x(p),obs_y(p),obs_z(p),ya(n,ie))
      end do
    end do
  end do
  call MPI_Allreduce(ya,ya,nobs*(nens+1),MPI_REAL8,MPI_SUM,comm,ierr)
  ya(:,nens+1)=sum(ya(:,1:nens),2)/real(nens)
  do m=1,nens
    ya(:,m)=ya(:,m)-ya(:,nens+1)
  end do

  !covariance relaxation and add mean back
  if(relax_adapt) relax_coef=adapt_relax_coef(yo,yb,ya,varo)
  select case (relax_opt)
    case (0) !no relaxation
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          u(:,:,:,m)=u(:,:,:,m)+um
      end do
    case (1) !RTPP
      if(proc_id==0) print *,'RTPP relax_coef = ',relax_coef
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) &
          u(:,:,:,m)=relax_coef*uf(:,:,:,m)+(1-relax_coef)*u(:,:,:,m)+um
      end do
    case (2) !RTPS
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
        hspec=halfspec(fftshift(spec))
        !select case (state_type) !convert state variable back to psi
          !case (1) !u
            !hspec=hspec/dcmplx(0.0,-ky)
          !case (2) !v
            !hspec=hspec/dcmplx(0.0,kx)
          !case (4) !zeta
            !hspec=hspec/dcmplx(-(kx**2+ky**2),0.0)
          !case (5) !temp
            !hspec=hspec/dcmplx(-sqrt(kx**2+ky**2),0.0)
        !end select
        uspec(:,:,k)=cmplx(hspec)
      end do
      call write_field(outfile,nkx,nky,nz,uspec)
    end if
  end do

  deallocate(x,y,z,kx,ky,dist,loc,cova)
  deallocate(uspec,spec,hspec,sig,sigf)
  deallocate(u,um,uf,umf,u_ms,um_ms,hu)

  if(proc_id==0) print*,'enkf complete'
  call parallel_finish()

end program enkf
