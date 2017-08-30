module mpi_util

   use MPI

   integer :: nprocs, proc_id, comm, ierr
   double precision :: time1,time2

   contains

   subroutine parallel_start()
      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, proc_id, mpi_ierr)
      call MPI_Comm_size(MPI_COMM_WORLD, nprocs, mpi_ierr)
      comm = MPI_COMM_WORLD
      time1 = MPI_Wtime()
   end subroutine parallel_start


   subroutine parallel_finish()
      time2 = MPI_Wtime()
      if(proc_id==0) print *,'total run time = ',time2-time1,' seconds.'
      call MPI_Finalize(ierr)
   end subroutine parallel_finish

end module mpi_util
