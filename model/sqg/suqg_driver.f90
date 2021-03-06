program suqg_driver 

  ! Stratified or barotropic spectral, homogeneous QG model
  !
  ! Routines: main, Get_rhs, Get_rhs_t
  !
  ! Dependencies: everything.

  use op_rules,        only: operator(+), operator(-), operator(*)
  use qg_arrays,       only: q,q_o,psi,psi_o,rhs,tracer,tracer_o, &
                             rhs_t,force_o,force_ot,filter,filter_t, &
                             qxg,qyg,ug,vg,unormbg,qdrag,hb,stir_field, &
                             kx_,ky_,ksqd_, Setup_fields
  use qg_params,       only: kmax,nz,filter_type,filter_exp,k_cut,use_topo, &
                             cr,ci,surface_bc,ubar_type,beta,e_o,topo_type, &
                             restarting,psi_init_type,use_tracer,&
                             filter_type_t,filter_exp_t,k_cut_t, &
                             tracer_init_type,parameters_ok,cntr,cnt, &
                             total_counts,start,diag1_step,diag2_step,time, &
                             d1frame,d2frame,frame,do_spectra,write_step, &
                             adapt_dt,dt_step,dt_tune,pi,i,nx,dt,robert, &
                             call_q,call_b,call_t,therm_drag,top_drag, &
                             therm_drag,kf_min,kf_max,forc_coef,forc_corr, &
                             norm_forcing,use_mean_grad_t,use_forcing_t, &
                             kf_min_t,kf_max_t,forc_coef_t,norm_forcing_t, &
                             linear,quad_drag,qd_angle,use_forcing,uscale,&
                             dealiasing,dealiasing_t,filt_tune,filt_tune_t, &
                             force_o_file,force_ot_file, &
                             Initialize_parameters
  use qg_run_tools,    only: Markovian,Write_snapshots
  use qg_init_tools,   only: Init_tracer, Init_topo, &
                             Init_streamfunction, Init_filter, Init_counters, &
                             Init_forcing
  use qg_diagnostics,  only: Get_energetics, Get_spectra, enstrophy
  use transform_tools, only: Init_transform, Spec2grid_cc, Grid2spec, Jacob, &
                             ir_prod, ir_pwr
  use numerics_lib,    only: March
  use io_tools,        only: Message, Write_field

  implicit none

  real,dimension(:,:),allocatable :: k_
  real                            :: e
  
  ! *********** Model initialization *********************

  call Initialize_parameters           ! Read/set/check params (in qg_params)

  call Message('This is ****SURFACE QG model****')
  call Message('Initializing model...')
  if (nz>1) then
     call Message('Error: Cant have nz>1 with Surface QG')
     parameters_ok = .false.
  endif

  call Init_counters                   ! (in qg_init_tools)
  call Init_transform(kmax,nz)         ! Init transform (in transform_tools)
  call Setup_fields                    ! Allocate/init fields (in qg_arrays)
  allocate(k_(-kmax:kmax,0:kmax))
  k_ = sqrt(ksqd_)

  filter = Init_filter(filter_type,filter_exp,k_cut,dealiasing,filt_tune,2.)

  if (use_topo) hb = Init_topo(topo_type,restarting)! Read/create bottom topo
  if (use_forcing) force_o = Init_forcing(forc_coef,forc_corr,kf_min,kf_max,&
                                          norm_forcing,force_o_file,restarting)

  psi = filter*Init_streamfunction(psi_init_type,restarting)  ! Read/init psi
  q = -k_*psi                                 ! Get init buoyancy 

  call Get_rhs                                         ! Get initial RHS

  if (use_tracer) then
     call Message('Tracers on')
     call Message('Any following messages regarding filter parameters')
     call Message('  refer to tracer filter: append _t to variable names')
     filter_t = Init_filter(filter_type_t,filter_exp_t,k_cut_t,dealiasing_t, &
          filt_tune_t,2.)
     if (use_forcing_t) force_ot = Init_forcing(forc_coef_t,forc_corr, &
                                                kf_min_t,kf_max_t,&
                                                norm_forcing_t,force_ot_file,&
                                                restarting)
     tracer = Init_tracer(tracer_init_type,restarting) ! Read/init tracer
     call Get_rhs_t
  endif

  if (.not.parameters_ok) then
     call Message('The listed errors pertain to values set in your input')
     call Message('namelist file - correct the entries and try again.', &
                   fatal='y')
  endif
     
  ! *********** Main time loop *************************

  call Message('Beginning calculation')

  do cntr = cnt, total_counts         

     start = (cntr==1)                  ! Flag true if 1st step of run

     ! Calculate diagnostics, write output
     if (mod(cntr,diag1_step)==0.or.start) d1frame = Get_energetics(d1frame)
     if (do_spectra.and.(mod(cntr,diag2_step)==0.or.start)) &
                                           d2frame = Get_spectra(d2frame)
     if (mod(cntr,write_step)==0.or.start) frame = Write_snapshots(frame)

     if (cntr==total_counts) call Write_field(psi,'output',1)

     if (adapt_dt.and.(mod(cntr,dt_step)==0.or.start)) & ! Adapt dt
        dt = dt_tune*pi/(kmax**2*sqrt(max(enstrophy(q),beta,1.)))

     q = filter*March(q,q_o,rhs,dt,robert,call_q)

     psi_o = psi                        ! Save for time lagged dissipation
     psi = -q*(1./k_)

     call Get_rhs                       ! See below

     if (use_tracer) then 
        tracer = filter_t*March(tracer,tracer_o,rhs_t,dt,robert,call_t)
        call Get_rhs_t                  ! See below
     endif

     time = time + dt                   ! Update clock

  enddo  ! End of main time loop

  call Message('Calculation done')

!*********************************************************************

contains

  ! Separate RHS calculations so that they can be conveniently
  ! called for initialization and in loop 

  !*********************************************************************

  subroutine Get_rhs

     ! Get physical space velocity and pv gradient terms for
     ! use in calculation of advection (jacobian) and quadratic drag

     if (.not.linear) then
        
        ug  = Spec2grid_cc(-i*ky_*psi)      ! Calculate derivatives and
        vg  = Spec2grid_cc(i*kx_*psi)       ! transform to grid space --
        if (use_topo) then
           qxg = Spec2grid_cc(i*kx_*(q+hb)) ! (staggered grid transforms packed
           qyg = Spec2grid_cc(i*ky_*(q+hb)) ! in complex part of x-space flds)
        else
           qxg = Spec2grid_cc(i*kx_*q) 
           qyg = Spec2grid_cc(i*ky_*q)
        endif
        
        ! Now do product in grid space and take difference back to k-space
        ! (ir_prod separately multiplies re and im parts of field, keeping
        ! staggered and straight grid forms in place)

        rhs = -Grid2spec(ir_prod(ug,qxg) + ir_prod(vg,qyg)) 

        ! Quadratic drag on bottom layer (ir_pwr raises field to power via
        ! method of ir_prod)

        if (quad_drag/=0) then  
           unormbg(:,:,1) = ir_pwr(ir_pwr(ug(:,:,nz),2.) &
                                 + ir_pwr(vg(:,:,nz),2.),.5)
           qdrag = quad_drag*filter &
             *(i*kx_*Grid2spec(unormbg*(ug*sin(qd_angle)+vg*cos(qd_angle))) &
              -i*ky_*Grid2spec(unormbg*(ug*cos(qd_angle)-vg*sin(qd_angle))))
           rhs(:,:,nz) = rhs(:,:,nz) - qdrag(:,:,1)
        endif

     endif

     if (beta/=0)       rhs = rhs + i*beta*(kx_*psi)
     if (uscale/=0)     rhs = rhs - uscale*i*(kx_*q)
     if (use_topo.and.uscale/=0) rhs = rhs - uscale*i*(kx_*hb)
     if (therm_drag/=0) rhs = rhs + therm_drag*k_*psi_o
     if (use_forcing)   rhs = rhs + Markovian(kf_min,kf_max, &
                           forc_coef,forc_corr,force_o,norm_forcing,psi)
     rhs = filter*rhs

  end subroutine Get_rhs

  !*********************************************************************

  subroutine Get_rhs_t

    stir_field = psi(:,:,1)

    rhs_t = -Jacob(stir_field,tracer) 
    if (use_mean_grad_t) rhs_t = rhs_t - i*(kx_*stir_field) 
    if (uscale/=0)       rhs_t = rhs_t - (i*uscale)*kx_*tracer
    if (use_forcing_t)   rhs_t = rhs_t + Markovian(kf_min_t,&
            kf_max_t,forc_coef_t,forc_corr,force_ot,norm_forcing_t,tracer)
    rhs_t = filter_t*rhs_t
    
  end subroutine Get_rhs_t

  !******************* END OF PROGRAM ********************************* 

end program suqg_driver
