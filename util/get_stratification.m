function [dz,rho,z,u] = get_stratification(nz,ptype,deltc,delrho,delu);

% [dz,rho,z,u] = GET_STRATIFICATION(nz,ptype,deltc,delrho,delu)  
%     Produces stratification profile, vertical discretization and
%     optionally, mean zonal velocity profile.  'nz' is number of
%     vertical levels, 'deltc' is 'scale depth' of potential density
%     profile, 'rho', 'delrho' is roughly normalized density 
%     difference between bottom and top.  Parameter
%     'ptype' lets you choose the functional form of the profile, 
%     with values:
%
%     'ptype'
%     
%     0  -  linear profile (constant N^2)
%     1  -  exponential profile: rho(z) = 1+delrho*(1-exp(z/deltc)) 
%     2  -  tanh^2 profile: (most realistic)
%           rho(z) = (rhotop+delrho*tanh^2(z/deltc))*(1-alpha*z)
%     3  -  double thermocline (needs direct editing right now)
%     
%     Finally, 'delu' is scale height for u = exp(-(z/delu)^2)
%
%     Returns layer thicknesses, dz, layer center positions, 
%     z, and the densities, rho.  Also returns velocity profile, u.

switch nargin
  case 4, delu = 0;
  case 3, delu = 0; delrho = 1;
  case 2,
    delu = 0; delrho = 1;
    if (ptype==1)|(ptype==2)
      error('must specify deltc with non-uniform stratification')
    end
  case 1, error('not enough input arguments')
end

% Set some internal parameters:

nzh = 100;           % for initial high res discretization to find zeros
alpha = .0007;       % linear slope to reduce steepness of rho near bot
rhotop = 1.;      % rho_bottom = rhotop*(1+alpha*h_bottom)

if ptype==0            % make linear profiles
   
   dz(1:nz,1)=1/nz;
   z(1) = -dz(1)/2;
   for n=2:nz
      z(n) = -(sum(dz(1:n-1))+dz(n)/2);
   end
   z=z';
   f = (-z+z(1))/(-z(nz)+z(1));        % 0 at top, 1 at bottom
   rhobot = -(rhotop+delrho)*alpha*z(nz) + delrho;
   rho = rhotop + (rhobot-rhotop)*f;
   u = 1-.5*f;
   
elseif (ptype==1|ptype==2|ptype==3)    % thermocline like profiles
   
   % First make high resolution version with linear discretization,
   % find zero crossings of highest mode for nz layers, set
   % layer interfaces to these positions and remake profiles
   % on new coordinate (this is method recommended by
   % A. Beckmann, 1986 (jpo)
   
   dzh(1:nzh,1) = 1/nzh;             % high res layer thicknesses-lin
   zh = get_z(dzh);                  % high res layer center pos'ns

   if ptype==1                         % high res density function
      rhoh = ones(nzh,1).*(1-alpha*zh) + (ones(nzh,1)-exp(zh/deltc))*delrho;
   elseif (ptype==2|ptype==3)
      rhoh = (rhotop+delrho*tanh(zh/deltc).^2).*(1-alpha*zh);  
%      rhoh = (1+(tanh(zh/deltc))**2)*(1-alpha*zh)
   end
   
   [kzh,vmodeh] = vmodes(dzh,rhoh,1); % high res stratification modes
   zih = cumsum(dzh);
   zih = zih(1:end-1);
   
   zi = abs(findzeros(vmodeh(:,nz+1),zh));     % length(zi)=nz-1=# of interfcs
   
   zi = (zi(2:end)+zi(1:end-1))/2;
                                    
   for n = 2:length(zi)
     dz(n) = zi(n)-zi(n-1);    % layer thicknesses
   end
   dz(1) = dz(2);
   dz(nz) = (1-zi(length(zi)));  % z=-1 at bottom of ocean
   dz=dz';
   z = get_z(dz);                    % positions of layer centers
   
   switch ptype                        % density subsampled on new z
   case 1,  rho = ones(nz,1).*(1-alpha*z) + (ones(nz,1)-exp(z./deltc))*delrho;
   case 2,  rho = (rhotop+delrho*tanh(z/deltc).^2).*(1-alpha*z);
   case 3,  rho = rho+delrho*.19*exp(-(z+.08).^2/.0008);
   end
     
   if delu==0
      f = (-z+z(1))/(-z(nz)+z(1));        % 0 at top, 1 at bottom
      rhobot = -(rhotop+delrho)*alpha*z(nz) + delrho;
      u = 1-.5*f;
   else
      u = exp(-(z/delu).^2);
   end
   
else
   error('illegal ptype value')
end 

% Normalize u to have zero mean

u = u - sum(u.*dz);
if (sum(abs(u).*dz)~=0) u = u/sum(abs(u).*dz);, end
if (u(1)<0) u=-u;, end
