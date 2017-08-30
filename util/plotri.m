function []=plotri(field)

% PLOTRI(field)  Plot real part of field in red, imaginary part
%     in blue.

clf
hold on
plot(real(field),'r')
plot(imag(field),'b')
hold off