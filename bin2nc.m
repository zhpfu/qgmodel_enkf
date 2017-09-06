%clear all
addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf';
expname='ctrl';
casename='sl16';
nens=32;

getparams([workdir '/' expname '/truth']);
n1=51; nt=100; dt=10;
for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt);
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  psi0(:,:,:,n)=spec2grid(psik);
  u0(:,:,:,n)=spec2grid(psi2u(psik));
  zeta0(:,:,:,n)=spec2grid(psi2zeta(psik));
  temp0(:,:,:,n)=spec2grid(psi2temp(psik));
  
	for m=1:nens
		psik1=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/f_' nid],nkx,nky,nz,1);
		psik2=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/' nid],nkx,nky,nz,1);
		psi1(:,:,:,m,n)=spec2grid(psik1);
		u1(:,:,:,m,n)=spec2grid(psi2u(psik1));
		zeta1(:,:,:,m,n)=spec2grid(psi2zeta(psik1));
		temp1(:,:,:,m,n)=spec2grid(psi2temp(psik1));
		psi2(:,:,:,m,n)=spec2grid(psik2);
		u2(:,:,:,m,n)=spec2grid(psi2u(psik2));
		zeta2(:,:,:,m,n)=spec2grid(psi2zeta(psik2));
		temp2(:,:,:,m,n)=spec2grid(psi2temp(psik2));
	end
end

	system(['rm -f ' workdir '/' expname '/' casename '/*.nc']);
	nc_write([workdir '/' expname '/' casename '/psi.nc'],'psi0',{'x','y','z','t'},psi0);
	nc_write([workdir '/' expname '/' casename '/psi.nc'],'psi1',{'x','y','z','m','t'},psi1);
	nc_write([workdir '/' expname '/' casename '/psi.nc'],'psi2',{'x','y','z','m','t'},psi2);
	nc_write([workdir '/' expname '/' casename '/zeta.nc'],'zeta0',{'x','y','z','t'},zeta0);
	nc_write([workdir '/' expname '/' casename '/zeta.nc'],'zeta1',{'x','y','z','m','t'},zeta1);
	nc_write([workdir '/' expname '/' casename '/zeta.nc'],'zeta2',{'x','y','z','m','t'},zeta2);
	nc_write([workdir '/' expname '/' casename '/u.nc'],'u0',{'x','y','z','t'},u0);
	nc_write([workdir '/' expname '/' casename '/u.nc'],'u1',{'x','y','z','m','t'},u1);
	nc_write([workdir '/' expname '/' casename '/u.nc'],'u2',{'x','y','z','m','t'},u2);
