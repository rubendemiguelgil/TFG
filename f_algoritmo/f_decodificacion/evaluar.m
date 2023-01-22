function [score] = evaluar(set_r_bins,clutter,n_para_deteccion,fi_apuntamiento_deg,resolucion)
%esta funcion realiza la evaluacion del porcentaje de visibilidad de un set
%recibiendo como parametro las celdas de distancia de dicho set,el numero de prf necesarias para detectar, el angulo de apuntamiento y el clutter simulado

%parametros 
t_pulso=resolucion;%no es el del radar, es el correspondiente a la resolucion ampliada (el del radar esta incluido en las funciones de simulacion y es 1e-6)
%convertimos a prf (los parametros son los del radar)
prfs=transpose(1./(set_r_bins*t_pulso));

%mapa de visibilidad
[mapa_visibilidad,x,y]=visibilidad_conjunto_optima_algo(clutter,prfs,n_para_deteccion,fi_apuntamiento_deg);

%visibilidad
total=400*size(mapa_visibilidad,1);
detecciones=0;
for i1=1:400%size(mapa_visibilidad,2)o 400 (60 km) o 467(70km) 534 deoende de si se evalua la visibilidad hasta 80 km o hasta 160 (maximo alcance)
    for j1=1:size(mapa_visibilidad,1)
     detecciones=detecciones+mapa_visibilidad(j1,i1);   
    end
end
porcentaje_visibilidad=(detecciones/total)*100;

%tiempo
tiempo=0;
t_trans=160e3*2/3e8;
for i1=1:size(set_r_bins,1)
   tiempo=tiempo+128*set_r_bins(i1)*1e-7+t_trans; 
end
k=0;
if(tiempo>0.065)
k=1e12;
end
%k=100;
score=porcentaje_visibilidad-k*tiempo;