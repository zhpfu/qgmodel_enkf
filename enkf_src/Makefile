OBJ=mpi.o fft.o file_io.o obs.o scales.o localization.o inflation.o grid.o stats.o dcdflib.o enkf.o

FFTW=/glade/u/apps/opt/fftw/3.3.4/intel/12.1.5

FC=mpif90
FCFLAGS=-f90=ifort -r8 -i4 -assume byterecl -ipo -nowarn -traceback
LIBS=-L$(FFTW)/lib -lfftw3 -L/user/lib64 -lm
LDFLAGS=$(LIBS)

all: enkf.exe

clean:
	rm -f *.o *.mod enkf.exe

mpi.o: mpi.f90
	$(FC) $(FCFLAGS) -c mpi.f90
fft.o: fft.f90
	$(FC) $(FCFLAGS) -I$(FFTW)/include -c fft.f90
file_io.o: file_io.f90
	$(FC) $(FCFLAGS) -c file_io.f90
scales.o: scales.f90 grid.o fft.o 
	$(FC) $(FCFLAGS) -c scales.f90
obs.o: obs.f90 grid.o fft.o
	$(FC) $(FCFLAGS) -c obs.f90
localization.o: localization.f90 stats.o scales.o grid.o mpi.o
	$(FC) $(FCFLAGS) -c localization.f90
inflation.o: inflation.f90 mpi.o
	$(FC) $(FCFLAGS) -c inflation.f90
grid.o: grid.f90
	$(FC) $(FCFLAGS) -c grid.f90
stats.o: stats.f90 dcdflib.o
	$(FC) $(FCFLAGS) -c stats.f90
dcdflib.o: dcdflib.f
	$(FC) $(FCFLAGS) -c dcdflib.f
enkf.o: enkf.f90
	$(FC) $(FCFLAGS) -c enkf.f90

enkf.exe: $(OBJ)
	$(FC) $(OBJ) -o enkf.exe $(LDFLAGS)
