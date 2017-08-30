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
  integer :: m,n,p,r,s,i,j,k,k1,nx,ny,nkx,nky,ns,nm,ie,v,nv,nobs
  character(256) :: arg,workdir,obsdir,nmlfile,infile,outfile,obfile

  real :: innov,varb,varo,norm,alpha
  complex,allocatable,dimension(:,:,:) :: uspec
  complex(C_DOUBLE_COMPLEX),allocatable,dimension(:,:) :: spec,hspec
  integer,allocatable,dimension(:,:) :: kx,ky
  integer,allocatable,dimension(:,:,:) :: x,y,z
  real,allocatable,dimension(:) :: hu,yo,obsv
  real,allocatable,dimension(:,:,:) :: um,uobs,sig,sigf,dist,cova,loc,ysave
  real,allocatable,dimension(:,:,:,:) :: u,umsave,um_ms
  real,allocatable,dimension(:,:,:,:,:) :: u_ms,usave,usavev

  integer :: kmax,nz,nens,localize_opt,ob_thin,find_roi,relax_opt
  real :: ob_err,obs_val,relax_coef
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
  allocate(kx(nkx,nky),ky(nkx,nky))
  allocate(dist(nx,ny,nz),loc(nx,ny,nz))
  allocate(cova(nx,ny,nz))
  allocate(uspec(nkx,nky,nz))
  allocate(spec(nx,ny),hspec(nkx,nky))
  allocate(u(nx,ny,nz,nm),um(nx,ny,nz))
  allocate(usave(nx,ny,nz,nm,2),umsave(nx,ny,nz,2))
  allocate(sig(nx,ny,nz),sigf(nx,ny,nz))
  allocate(uobs(nx,ny,nz))
  allocate(u_ms(nx,ny,nz,ns,nm),um_ms(nx,ny,nz,ns))
  allocate(hu(nens+1))

  call grid3d((/(i,i=1,nx)/),(/(i,i=1,ny)/),(/(i,i=1,nz)/),x,y,z)

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
        spec=fullspec(dcmplx(uspec(:,:,k)))
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
  usave(:,:,:,:,1)=u; umsave(:,:,:,1)=um !prior perturbation and mean

  !adaptively find optimal roi
  if(localize_opt==2) then
    if(proc_id==0) print *,'adaptive localization:'
    if(find_roi==1) &
      call find_optimal_roi_mac(nens,u,kr,roi)
    if(find_roi==2) &
      call find_optimal_roi_chi(nens,u,kr,roi)
  end if

  !assimilation loop
  nobs=0
  do k=1,1 
  do j=1,ny,ob_thin
  do i=1,nx,ob_thin
    p=(k-1)*nx*ny+(j-1)*ny+i

    do v=1,nv !variable loop
      nobs=nobs+1

      select case (obt(v))
        case (1)
          obs_val=obs_u(p) !u
        case (2) 
          obs_val=obs_v(p) !v
        case (3) 
          obs_val=obs_psi(p) !psi converted from uv
        case (4) 
          obs_val=obs_zeta(p) !zeta converted from uv
        case (5) 
          obs_val=obs_psi1(p) !psi equiv gauss noise
        case (6) 
          obs_val=obs_zeta1(p) !zeta equiv gauss noise
      end select

      !observation prior
      call grid2d((/(i,i=-kmax,kmax)/),(/(j,j=0,kmax)/),kx,ky)
      hu=0.0
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) then
          uobs=u(:,:,:,m)+um
          do k1=1,1  !no interp in vertical
            spec=dcmplx(uobs(:,:,k1),0.0)
            spec=fft2(spec)/(nx*ny)
            spec=fftshift(spec)
            hspec=halfspec(spec)
            select case (obt(v))
              case (1) 
                hspec=dcmplx(0.0,-ky)*hspec !u
              case (2) 
                hspec=dcmplx(0.0,kx)*hspec !v
              case (4,6) 
                hspec=-dcmplx(kx**2+ky**2,0.0)*hspec !zeta
            end select
            spec=fullspec(hspec)
            spec=ifftshift(spec)
            uobs(:,:,k1)=real(ifft2(spec))
          end do
          call obs_interp(x,y,z,uobs,obs_x(p),obs_y(p),obs_z(p),hu(ie))
        end if
      end do
      call MPI_Allreduce(hu,hu,nens+1,MPI_REAL8,MPI_SUM,comm,ierr)
      hu(nens+1)=sum(hu(1:nens))/real(nens)
      do m=1,nens
        hu(m)=hu(m)-hu(nens+1)
      end do

      innov=obs_val-hu(nens+1)
      !if(abs(innov)>(1*ob_err)) then
        !if(proc_id==0) print *,'kick off'
        !cycle
      !end if

      varb=sum(hu(1:nens)**2)/real(nens-1)
      varo=ob_err**2
      !varo=innov**2 !Huber norm or AOEI
      norm=varo+varb
      alpha=1.0/(1.0+sqrt(varo/norm))

      !distance between obs and x
      dist=sqrt((min(abs(x-obs_x(p)),abs(nx-x+obs_x(p))))**2 + &
                (min(abs(y-obs_y(p)),abs(ny-y+obs_y(p))))**2)
    
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
        loc=local_func(dist,roi(s),localize_opt)

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
        write(*,'(a,i7,i3,a,f6.2,a,f6.2,a,f5.2,a,f7.2,f7.2)') 'No',p, obt(v), &
           ' (',obs_x(p),',',obs_y(p),',',obs_z(p),') ',obs_val,hu(nens+1)

    end do !variable loop

  end do
  end do
  end do !assimilation loop

  usave(:,:,:,:,2)=u; umsave(:,:,:,2)=um !posterior perturbation and mean

  !covariance relaxation and add mean back
  !adaptive algorithm needs O A and B in obs space  
  call grid2d((/(i,i=-kmax,kmax)/),(/(j,j=0,kmax)/),kx,ky)
  allocate(obsv(nrec),usavev(nx,ny,nz,nm,2),yo(nobs),ysave(nobs,nens+1,2))
  n=0
  ysave=0.0
  do v=1,nv
    select case (obt(v))
      case (1) !u
        obsv=obs_u
      case (2) !v
        obsv=obs_v
      case (3) !psi converted from uv
        obsv=obs_psi
      case (4) !zeta converted from uv
        obsv=obs_zeta
      case (5) !psi equiv gauss noise
        obsv=obs_psi1
      case (6) !zeta equiv gauss noise
        obsv=obs_zeta1
    end select
    do r=1,2  !prior and posterior
      do m=1,nm
        ie=(m-1)*nprocs+proc_id+1
        if(ie<=nens) then
          uobs=usave(:,:,:,m,r)+umsave(:,:,:,r)
          do k=1,nz
            spec=dcmplx(uobs(:,:,k),0.0)
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
            usavev(:,:,k,m,r)=real(ifft2(spec))
          end do
        end if
      end do
    end do

    do k=1,1 
    do j=1,ny,ob_thin
    do i=1,nx,ob_thin
      n=n+1
      p=(k-1)*nx*ny+(j-1)*ny+i
      yo(n)=obsv(p)
      do r=1,2  !prior and posterior
        do m=1,nm
          ie=(m-1)*nprocs+proc_id+1
          if(ie<=nens) &
            call obs_interp(x,y,z,usavev(:,:,:,m,r),obs_x(p),obs_y(p),obs_z(p),ysave(n,ie,r))
        end do
      end do
    end do
    end do
    end do
  end do
  call MPI_Allreduce(ysave,ysave,nobs*(nens+1)*2,MPI_REAL8,MPI_SUM,comm,ierr)
  ysave(:,nens+1,:)=sum(ysave(:,1:nens,:),2)/real(nens)
  do m=1,nens
    ysave(:,m,:)=ysave(:,m,:)-ysave(:,nens+1,:)
  end do

  if(relax_adapt) relax_coef=adapt_relax_coef(yo,ysave,varo)

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
          u(:,:,:,m)=relax_coef*usave(:,:,:,m,1)+(1-relax_coef)*usave(:,:,:,m,2)+um
      end do

    case (2) !RTPS
      sigf=0.0
      sig=0.0
      call MPI_Allreduce(sum(usave(:,:,:,:,1)**2,4),sigf,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
      call MPI_Allreduce(sum(usave(:,:,:,:,2)**2,4),sig,nx*ny*nz,MPI_REAL8,MPI_SUM,comm,ierr)
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

  deallocate(x,y,z,kx,ky,dist,loc,cova)
  deallocate(uspec,spec,hspec,sig,sigf)
  deallocate(u,um,usave,umsave,ysave,u_ms,um_ms,hu)

  if(proc_id==0) print*,'enkf complete'
  call parallel_finish()

end program enkf
