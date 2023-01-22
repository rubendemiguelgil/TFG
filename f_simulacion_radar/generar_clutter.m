function [clutter] = generar_clutter(fi_apuntamiento_deg)

prf_input_muestreo=38000;%hay que ajustarla para que el numero de range bins sea entero
%parametros del radar
%altura
h=1000;
%velocidad
v=1000/3.6;
%potencia media
P_avg=1000;%(en W) 
%tiempo de pulso sin comprimir
t_pulso_sin=1e-6/6;
dif_r_clutter_sinsolapar=3e8*t_pulso_sin;
n_bins_sinsolapar=round(1/(prf_input_muestreo*t_pulso_sin));%range bins (lo redondeamos para ajustar asi a la prf mas cercana)
prf_muestreo=1/(t_pulso_sin*n_bins_sinsolapar);%prf ajustada
nf=512; %justificar

f=10*10^9;%frecuencia de la portadora
lambda=3*10^8/f;
tot_1=2*nf*1/prf_muestreo;%periodo*numero de pulsos (utilizamos potencia media)(nf*2 por ser nf unilateral)
theta_apuntamiento_deg=1;
theta_apuntamiento_rad=theta_apuntamiento_deg*pi/180;
%fi_apuntamiento_deg=60;
fi_apuntamiento_rad=fi_apuntamiento_deg*pi/180;
perdidas=1; %suponemos 0 db(sin perdidas)

%ec de alcance (4/3 es el valor generico para climas templados)
R_e=4/3;
r_tierra=6371;
dmax=sqrt(2*R_e*h/1000*r_tierra);%dmax será la distancia desde el avion al horizonte y, por lo tanto, la posicion del ultimo clutter de suelo que llega al avion

n_total=ceil(dmax*1000/dif_r_clutter_sinsolapar);
%min 2 muestras por celda
dif_r_clutter_sinsolapar_rejilla=dif_r_clutter_sinsolapar/2;
%DFT x puntos

dif_f=prf_muestreo/nf;
%como necesitamos al menos dos muestras
dif_f_rejilla=prf_muestreo/(nf);
%resolucion en azimuth (criterio DFT)

dif_az_min1=acos(1-((dif_f_rejilla*lambda)/(2*v)));

%resolucion en azimuth (criterio 8 muestras)
%el ancho a -3 dB en azimuth es 1,.95ª (definido en prueba_antena.m)

dif_az_min2= (1.95/8)*2*pi/360;


dif_az_min= min(dif_az_min1,dif_az_min2);
%creamos la rejilla (en rango-azimuth)
n_rangos=ceil(dmax*1000/dif_r_clutter_sinsolapar_rejilla);
n_azimuths=floor(2*pi/dif_az_min);%redondeo hacia abajo para que no se repita el ultimo
rejilla=ones(n_azimuths,n_rangos);%al estar muy lejor no hace falta ajustar la longitud de la rejilla sobre la tierra (pues es aproximadamente la misma que la de rangos vista desde el avion)
%creamos también la rejilla rango-doppler (mapa de clutter no solapado)
%max_doppler=abs(2*v)/lambda;

nf_max=2*ceil(prf_muestreo/dif_f);
clutter=zeros((nf_max),n_total);
%rellenamos cada celda con su potencia de clutter 
for i1=1:size(rejilla,2) %recorre rangos (columnas)
    %obtenemos el ángulo de visión y la distancia (elevación)
    distancia=i1*dif_r_clutter_sinsolapar_rejilla;
    rango=sqrt(distancia^2+h^2);
    theta=atan(h/distancia);
    grazing_angle=theta;
    
       %distancia
    n_celda_r=(rango/dif_r_clutter_sinsolapar);
    n_celda_r_inf=floor(n_celda_r);
    n_celda_r_sup=ceil(n_celda_r);
    
    %calculamos el reparto de potencias
    pot_inf_r=1-(n_celda_r-n_celda_r_inf);
    pot_sup_r=1+n_celda_r-n_celda_r_sup;
    
    %evitamos que exceda los limites
    
    if(n_celda_r<1)
        n_celda_r_inf=size(clutter,2);
        n_celda_r_sup=1;
    elseif(n_celda_r>size(clutter,2))
        n_celda_r_inf=size(clutter,2);
        n_celda_r_sup=size(clutter,2);%en distancia no pasamos la potencia a la primera celda, sino que la metemos en la ultima (la distancia no es periodica)
        pot_sup_r=0;%le ponemos cero potencia, pues esta celda se saldria del array
    end
   
    %area celda
    area=dif_az_min*distancia*dif_r_clutter_sinsolapar_rejilla;
   
    for j1=1:size(rejilla,1) %recorre azimuths (filas)
    fi=j1*dif_az_min;
 
    
    
    
     %le asignamos su potencia segun la ecuacion de alcanze
    rejilla(j1,i1)=(P_avg*(ganancia(theta-theta_apuntamiento_rad,fi-fi_apuntamiento_rad))^4*area*radar_cross_sec(grazing_angle)*lambda^2)/((4*pi)^3*rango^4*perdidas);
    %colocamos su potencia en la celda que le corresponda(primero hayamos su celda en distancia y después en frecuencia doppler)
  
 
    
    
    %doppler
    desp_d=2*cos(fi)*cos(theta)*v/lambda;
    
    n_celda_d=(desp_d/dif_f)+nf_max/2;
    n_celda_d_inf=floor(n_celda_d);
    n_celda_d_sup=ceil(n_celda_d);
    pot_inf_d=1-(n_celda_d-n_celda_d_inf);
    pot_sup_d=1+n_celda_d-n_celda_d_sup;
    %cuando exceda los limites la asignamos a la celda del extremo contrario (es periódico) (darse cuentra de que lo hacemos despues de calcular su fraccion de potencia a partir de los indices cuando estos  si podian exceder los límites
   
    if(n_celda_d<1)
        n_celda_d_inf=size(clutter,1);
        n_celda_d_sup=1;
    elseif(n_celda_d>size(clutter,1))
        n_celda_d_inf=size(clutter,1);
        n_celda_d_sup=1;
    end
   
    %una vez obtenidas las celdas dividimos la potencia dependiendo de las celdas en las que caiga
    
    
    clutter(n_celda_d_inf,n_celda_r_inf)=clutter(n_celda_d_inf,n_celda_r_inf)+rejilla(j1,i1)*pot_inf_r*pot_inf_d;
    clutter(n_celda_d_sup,n_celda_r_inf)=clutter(n_celda_d_sup,n_celda_r_inf)+rejilla(j1,i1)*pot_inf_r*pot_sup_d;
    
        
    
    clutter(n_celda_d_inf,n_celda_r_sup)=clutter(n_celda_d_inf,n_celda_r_sup)+rejilla(j1,i1)*pot_sup_r*pot_inf_d;
    clutter(n_celda_d_sup,n_celda_r_sup)=clutter(n_celda_d_sup,n_celda_r_sup)+rejilla(j1,i1)*pot_sup_r*pot_sup_d;
    
    end
end
%se desheterodiniza el clutter para situar el lobulo principal en el cero, asi las velocidades seran respecto al avion, que se considerara a velocidad cero
f_lobulo=2*v*cos(fi_apuntamiento_rad)*cos(theta_apuntamiento_rad)/lambda;
celda_lobulo=size(clutter,1)-round((f_lobulo/dif_f));
clutter=circshift(clutter,celda_lobulo,1);
