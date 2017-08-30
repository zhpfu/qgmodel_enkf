function [f,s] = sortvec(v)

% [f,s] = SORTVEC(v)  
%     Sort vector v in increasing order and store
%     in f.  Also get index conversion s.

nz = length(v);
f = v;

for j = 2:nz
  for i = j:-1:2
    if f(i)<f(i-1)
      temp = f(i);
      f(i)=f(i-1);
      f(i-1)=temp;
    end
  end
end

for j = 1:nz
  for i = 1:nz
    if (f(i) == v(j)) s(j)=i; end
  end
end

