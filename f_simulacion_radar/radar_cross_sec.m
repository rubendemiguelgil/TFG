function [sigma_0] = radar_cross_sec(Theta) %theta es el angulo de vision desde la horizontal del avion, no desde el eje de la antena
sig_0s=10^(-0.5);
sig_0d=10^(-1.3);
fi_0=5.339;
gamma_rad=Theta;
gamma_deg=gamma_rad*360/(2*pi);
sigma_0=sig_0d*sin(gamma_rad)+sig_0s*exp(-(90-gamma_deg).^2/fi_0^2);
