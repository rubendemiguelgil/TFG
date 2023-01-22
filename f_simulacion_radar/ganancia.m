function [gs] = ganancia(theta,fi)
%{
theta_3db=1.6*pi/180;
fi_3db=3.9*pi/180;
gmax=35;
gls=30;
Asls=1.84;

A=atan2(sin(fi),(sin(theta).*cos(fi)));
R_3db=(theta_3db*fi_3db)/sqrt((cos(A)*fi_3db).^2+(sin(A)*theta_3db).^2);
R=acos(cos(theta).*cos(fi))./(R_3db/2);

R1=sqrt(2);
R2=R1*(2*sqrt(2)+1);
R2_1=R1*(2*sqrt(2)+1)*Asls;
R3=4.25*R2;

if(R<=R1)
     gs= 10^(gmax/20)*sqrt(1-2*(R/2)^2);
elseif(R<=R2_1)&&(R>R1)
     gs=10^((gmax-gls)/20)*cos(pi*(R-R1)/2+pi/2)*cos(4*A);
elseif(R<=R3)&&(R>R2_1)
     gs=10^((gmax-gls)/20)*cos(pi*(R-R2)/2+pi/2)*exp(-0.25*(R-R2_1)/2)*cos(4*A);
elseif(R>R3)
     gs=10^((gmax-gls)/20)*cos(pi*(R-R2)/2+pi/2)*exp(-0.25*(R3-R2_1)/2)*cos(4*A);
end
%}

theta_3db=4.6*pi/180;
fi_3db=3.9*pi/180;
gmax=35;
gls=25;
Asls=1.84;

A=atan2(sin(fi),(sin(theta).*cos(fi)));
R_3db=(theta_3db*fi_3db)/sqrt((cos(A)*fi_3db).^2+(sin(A)*theta_3db).^2);
R=acos(cos(theta).*cos(fi))./(R_3db/2);

R1=sqrt(2);
R2=R1*(2*sqrt(2)+1);%ASLs se ha puesto y quitado haciendo pruebas
R2_1=R1*(2*sqrt(2)+1)*Asls;
R3=4.25*R2_1;

if(R<=R1)
     gs= 10^(gmax/20)*sqrt(1-2*(R/2)^2);
elseif(R<=R2_1)&&(R>R1)
     gs=10^((gmax-gls)/20)*cos(pi*(R-R1)/2+pi/2)*cos(4*A);
elseif(R<=R3)&&(R>R2_1)
     gs=10^((gmax-gls)/20)*cos(pi*(R-R2)/2+pi/2)*exp(-0.25*(R-R2_1)/2)*cos(4*A);
elseif(R>R3)
     gs=10^((gmax-gls)/20)*cos(pi*(R-R2)/2+pi/2)*exp(-0.25*(R3-R2_1)/2)*cos(4*A);
end
%ganancia buena
