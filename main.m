clear all
close all
clc

load naca1.dat
X=naca1(:,1);
Y=naca1(:,2);

P0 = 101325;
h = 100;

chord = 0.03; velocity = 80; viscosity = 0.0000178;
k = 1.4; R = 287;  

P = P0 * exp( -1.256*10^(-4) * h);
T = 18 - 6 * h / 1000 + 273.15;

density = 1.293 * (P/101325) * (273.15/T);
RE = density * chord * velocity / viscosity 
MACH = velocity/sqrt(k*R*T) 

% RE=6e6;
% MACH=0;
alpha=2;


tic
[p]=xfoil(X,Y,alpha,RE,MACH);
toc


CL=p.cl;
CD=p.cd;
CM=p.cm;
figure(1)
plot(p.x,p.y)
axis equal
figure(2)
if (RE~=0 || MACH~=0)
    plot(p.x,p.y-2,p.x,-p.cpi,p.x,-p.cpv)
    xlabel('x')
    ylabel('-C_p')
    legend('airfoil','cpi','cpv')
    xlim([-0.1 2])
    grid on
else
    plot(p.x,p.y-2,p.x,-p.cpi)
    xlabel('x')
    ylabel('-C_p')
    legend('airfoil','cpi')
    xlim([-0.1 2])
    grid on
end