function hu = obs_operator(x,y,z,u,obs_x,obs_y,obs_z)

%hu=interpn(x,y,z,u,obs_x,obs_y,obs_z);
hu=u(obs_x,obs_y,obs_z);
