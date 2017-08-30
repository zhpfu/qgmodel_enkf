colormap(colormap_ncl('/wall/s0/yxy159/graphics/colormap/BlWhRe.rgb',41))

getparams('/wall/s0/yxy159/qgmodel_enkf/sqg/truth');
psik=read_field(f,nkx,nky,nz,1);

%figure('position',[1 1 800 600])
%subplot(2,2,3)
contourf(spec2grid(psik)',-2:0.1:2,'linestyle','none'); caxis([-2 2]); colorbar
axis equal; axis([1 nx 1 ny]);

%subplot(2,2,4)
%contourf(spec2grid(psi2temp(psik))',-5:0.5:5,'linestyle','none'); caxis([-5 5]); colorbar
%axis equal; axis([1 nx 1 ny]);
title(strrep(f,'_','\_'))

