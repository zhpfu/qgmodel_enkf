function plotspec(w,p,smth,color,linetype,linewidth)

p=smooth_spec(w,p,smth);

%loglog(w,p,'-','color',[.7 .7 .7],'linewidth',1); hold on 

logw=log(w(2:end));
n=100;
logw1=0:logw(end)/n:logw(end);
w1=exp(logw1);

logp1=interp1(logw,log(p(2:end)),logw1);
p1=exp(logp1);

loglog(w1,p1,linetype,'color',color,'linewidth',linewidth)

