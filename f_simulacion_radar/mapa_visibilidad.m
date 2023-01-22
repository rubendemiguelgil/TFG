function [mapa,prf_ajustada,x,y] = mapa_visibilidad(clutter,prf_input,fi_apuntamiento_deg)
%parametros radar y de generacion de clutter
prf_input_muestreo=38000;%hay que ajustarla para que el numero de range bins sea entero
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
nf=512; %justificar (256=positivo mas negativo)

f=10*10^9;%frecuencia de la portadora
lambda=3*10^8/f;
tot_1=2*nf*1/prf_muestreo;%periodo*numero de pulsos (utilizamos potencia media)(nf*2 por ser nf unilateral)
perdidas=1; %suponemos 0 db(sin perdidas)

dif_f=prf_muestreo/nf;
nf_max=2*ceil(prf_muestreo/dif_f);
%mapa solapado
%apuntamientos
theta_apuntamiento_deg=1;
theta_apuntamiento_rad=theta_apuntamiento_deg*pi/180;
fi_apuntamiento_rad=fi_apuntamiento_deg*180/pi;
%parametros para el mapa solapado
t_pulso_sol_comprimido=1e-6;
t_pulso_sol_sin_compresion=7e-6;
t_emision=8e-6;%tiempo de pulso sin comprimir mas tiempo de conmutacion de receptor a transmisor
rango_ciego=3e8*t_emision/2;%tiempo en el que el receptor no recibe nada
n_filtros_dft=128;
n_range_bins_sol=round(1/(prf_input*t_pulso_sol_comprimido));
prf=1/(n_range_bins_sol*t_pulso_sol_comprimido);
tot_2=n_filtros_dft/prf;

r_unambiguo=3*10^8/(2*prf);
res_dist_sol=r_unambiguo/n_range_bins_sol;

%ciclo de trabajo
d_cicle=t_pulso_sol_sin_compresion*prf;
%potencia
P_pico=14000;
P_avg_2=P_pico*d_cicle;

clutter_sol=zeros(n_filtros_dft,n_range_bins_sol);

for i1=1:size(clutter,2)
        %rangos
        rango=dif_r_clutter_sinsolapar*i1;
        n_celda_r=((rango/r_unambiguo)-floor(rango/r_unambiguo))*n_range_bins_sol;
        n_celda_r_inf=floor(n_celda_r);
        n_celda_r_sup=ceil(n_celda_r);
        %areas (en dist-frec para facilitar el calculo)
        %area_sinsolapar=dif_f*dif_r_clutter_sinsolapar;
        %area_solapada=res_doppler*res_dist_sol;
        
        
       %calculamos el reparto de potencias
       pot_inf_r=1-(n_celda_r-n_celda_r_inf);
       pot_sup_r=1+n_celda_r-n_celda_r_sup;
    
       %evitamos que exceda los limites
    
       if(n_celda_r<1)
           n_celda_r_inf=size(clutter_sol,2);
           n_celda_r_sup=1;
       elseif(n_celda_r>size(clutter_sol,2))
           n_celda_r_inf=size(clutter_sol,2);
           n_celda_r_sup=size(clutter_sol,2);%en distancia no pasamos la potencia a la primera celda, sino que la metemos en la ultima (la distancia no es periodica)
           pot_sup_r=0;%le ponemos cero potencia, pues esta celda se saldria del array
       end
    for j1=1:size(clutter,1)
      
        %frecuencias
        frecuencia=dif_f*(j1-nf_max/2-1);
        n_celda_d=((frecuencia/prf)-floor(frecuencia/prf))*n_filtros_dft;%esta bien, para los negativos los mete arriba del todo
        n_celda_d_inf=floor(n_celda_d);
        n_celda_d_sup=ceil(n_celda_d);
        
        pot_inf_d=1-(n_celda_d-n_celda_d_inf);
        pot_sup_d=1+n_celda_d-n_celda_d_sup;
        %cuando exceda los limites la asignamos a la celda del extremo contrario (es periódico) (darse cuentra de que lo hacemos despues de calcular su fraccion de potencia a partir de los indices cuando estos  si podian exceder los límites
   
        if(n_celda_d<1)
            n_celda_d_inf=size(clutter_sol,1);
            n_celda_d_sup=1;
        elseif(n_celda_d>size(clutter_sol,1))
            n_celda_d_inf=size(clutter_sol,1);
            n_celda_d_sup=1;
        end
        
        %asignamos las nuevas potencias
        
        clutter_sol(n_celda_d_inf,n_celda_r_inf)=clutter_sol(n_celda_d_inf,n_celda_r_inf)+(P_avg_2/P_avg)*clutter(j1,i1)*pot_inf_r*pot_inf_d;
        clutter_sol(n_celda_d_sup,n_celda_r_inf)=clutter_sol(n_celda_d_sup,n_celda_r_inf)+(P_avg_2/P_avg)*clutter(j1,i1)*pot_inf_r*pot_sup_d;
        
        clutter_sol(n_celda_d_inf,n_celda_r_sup)=clutter_sol(n_celda_d_inf,n_celda_r_sup)+(P_avg_2/P_avg)*clutter(j1,i1)*pot_sup_r*pot_inf_d;
        clutter_sol(n_celda_d_sup,n_celda_r_sup)=clutter_sol(n_celda_d_sup,n_celda_r_sup)+(P_avg_2/P_avg)*clutter(j1,i1)*pot_sup_r*pot_sup_d;
    end
end

%mapa de visibilidad desde -500 a 1500 km/h y hasta 160 km
d_cubrir=160;%km
sn_requerida=11.483;%justificado por el uso de un ca-cfar
rcs_blanco=1;%m^2
%definimos los limites del mapa y calculamos su resolucion en m/s
v_max=2500;
v_min=-500;

span_v=(v_max-v_min)/3.6;%span de velocidades a medir en m/s (respecto a nuestro avión

%res_v=res_doppler*lambda/2;
res_v=1;%m/s
%creamos la matriz
n_velocidades=floor(span_v/res_v);
n_rangos=round(d_cubrir*1000/res_dist_sol);

visibilidad=zeros(n_velocidades,n_rangos);


%calculamos el ancho de banda entre nulos de la antena y la posicion del lobulo principal para poder eliminarlo del mapa de visibilidad
    %posicion
    f_lobulo=2*v*cos(fi_apuntamiento_rad)*cos(theta_apuntamiento_rad)/lambda;
    %anchos de banda
        %fi
        fi=-pi:0.000005:pi;
        theta=0;
        gt=ganancia(0,0);
        for j=1:size(fi,2)
               g_db=20*log10(ganancia(theta,fi(j))/gt);
                if (g_db>-25)
                bw_unilateral_fi=abs(fi(j));    
                break;
                end
        end
        %theta
        %{
        theta=-pi/2:0.000005:pi/2;
        fi=0;
        gt=ganancia(0,0);
        for j=1:size(theta,2)
               g_db=10*log10(ganancia(theta(j),fi)/gt);
                if (g_db>-6)
                bw_unilateral_theta=abs(theta(j));    
                break;
                end
        end
        %}
    %posicion de los nulos (como la antena es mas ancha en fi que en theta las zonas de mayor desp doppler seran los extremos del lhaz segun la coordenada fi)
    f_semihaz_sup=2*v*cos(fi_apuntamiento_rad-bw_unilateral_fi)*cos(theta_apuntamiento_rad)/lambda-f_lobulo;%semiancho de haz superior
    f_semihaz_inf=f_lobulo-2*v*cos(fi_apuntamiento_rad+bw_unilateral_fi)*cos(theta_apuntamiento_rad)/lambda;%semiancho de haz inferior
    
    f_max_amb=abs(f_semihaz_sup);%el lobulo principal esta en cero, por lo que desplegamos los anchos de haz alrededor de cero
    f_min_amb=-abs(f_semihaz_inf);
    f_max_no_amb=(f_max_amb/prf-floor(f_max_amb/prf))*prf;%eliminamos la ambiguedad (en la parte positiva no es necesaria esta sentencia)
    f_min_no_amb=(f_min_amb/prf-floor(f_min_amb/prf))*prf;%eliminamos la ambiguedad (pasamos la parte negativa a su repeticion positiva)
%recorremos el mapa de clutter solapado revisando donde se cumple la
%especificacion de snr

for i1=1:size(visibilidad,2)
     %obtenemos el rango 
     rango=i1*res_dist_sol;
     
     
     %obtenemos la potencia devuelta por nuestro blanco
     p_rec=(P_avg*(ganancia(0,0))^4*rcs_blanco*lambda^2)/((4*pi)^3*rango^4*perdidas);
     %no se ha tenido en cuenta la h de los blacos (se supuso la misma que para el radar)
     
     %obtenemos la celda del clutter sol en la que caería
     n_celda_r=1+floor(((rango/r_unambiguo)-floor(rango/r_unambiguo))*n_range_bins_sol);
      
   for j1=1:size(visibilidad,1)
      %obtenemos velocidad para nuestra velocidad-rango
      velocidad=j1*res_v+v_min/3.6;
      f_doppler=2*velocidad/lambda;%la velocidad positiva es la de acercamiento, de ahi que no pongamos el signo menos
   
      %eliminamos la visibilidad de las zonas ciegas
          %lobulo principal
          if(((f_doppler/prf-floor(f_doppler/prf))*prf<f_max_no_amb)||((f_doppler/prf-floor(f_doppler/prf))*prf>f_min_no_amb))%como el lobulo esta en torno a cero se usara || 
             visibilidad(j1,i1)=0; 
         
          %transmisor emitiendo
          elseif((rango/r_unambiguo-floor(rango/r_unambiguo))*r_unambiguo<=rango_ciego)
              visibilidad(j1,i1)=0;
          else     
   
          %obtenemos la celda del clutter sol en la que caería
          n_celda_d=floor(1+((f_doppler/prf)-floor(f_doppler/prf))*n_filtros_dft);

          %snr
          snr=10*log10(p_rec/clutter_sol(n_celda_d,n_celda_r));
          %si se cumple la snr requerida visibilidad valdra 1
              if(snr>sn_requerida)
              visibilidad(j1,i1)=1;
              end  
          end
    end
end
prf_ajustada=prf;
mapa=visibilidad;
x=1:size(visibilidad,2);
x=x*res_dist_sol/1000;
y=1:size(visibilidad,1);
y=y*res_v*3.6+v_min;