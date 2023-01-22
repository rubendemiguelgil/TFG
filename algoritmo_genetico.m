addpath('f_algoritmo\f_tratamiento')
addpath('f_algoritmo\f_decodificacion')
addpath('f_simulacion_radar')
addpath('f_simulacion_radar/f_simulacion_algoritmo')
%%
clear,clc,clf;
%algoritmo genetico

 %parametros radar
    %velocidad
    v=1000/3.6;
    %frecuencia de la portadora
    f=10*10^9;
    lambda=3e8/f;
    %apuntamiento en azimuth
    fi_apuntamiento_deg=60;
    fi_apuntamiento_rad=fi_apuntamiento_deg*pi/180;
    %apuntamiento en elevacion
    theta_apuntamiento_deg=1;
    theta_apuntamiento_rad=theta_apuntamiento_deg*pi/180;
    %duty cicle (para la primera)
    d_cicle=0.02;%justificar
    %duracion pulso (para la resolucion en distancia)
    t_pulso=1e-7;%resolucion alta (mayor q el tamaño de la celda)
    res_dist=3e8*t_pulso/2;
    %clutter
    clutter=generar_clutter(fi_apuntamiento_deg);
    
%configuracion del set
n_para_deteccion=2;
n_prf_set=6;
%prf desde 25Khz a 8000
 pri_min=350;%esta en multiplos del t_pulso de 1e-8
 pri_max=1500;
 prf_min=round(1/(pri_max*t_pulso));
 prf_max=round(1/(pri_min*t_pulso));
 n_posibilidades=pri_max-pri_min+1;
 
%configuracion algoritmo
%maximas generaciones
max_gen=100;
%poblacion
n_individuos=50;

opciones=pri_min:1:pri_max;

 %generador de los individuos de la poblacion inicial 
 
 generacion1=generador_individuos(n_individuos,n_prf_set);
 arbol_genealogico=generacion1; 
 elegidos=generacion1;
%%
scores=evaluar_generacion(generacion1,opciones,clutter,n_para_deteccion,fi_apuntamiento_deg,t_pulso);
scores_padre=scores;
%generacon de la segunda generacion
%generacion2=generador_individuos(n_individuos,n_prf_set);
%arbol_genealogico=[arbol_genealogico; generacion2];
%scores=[scores evaluar_generacion(generacion2,opciones,clutter,n_para_deteccion,fi_apuntamiento_deg)];

%concatenamos las generaciones para su evaluacion
%individuos_evaluados=[generacion1 generacion2];


%evaluacion individuos de la primera y segunda generacion para inicializar el algoritmo
%scores=evaluar_generacion(individuos_evaluados,opciones,clutter,n_para_deteccion,fi_apuntamiento_deg,t_pulso);
%{
%informacion para la consola
fprintf('GENERACION BASE');
fprintf('mean:');
disp(mean(scores));
[valor,indice]=max(scores);
fprintf('best:');
disp(valor);
%}
%variable para almacenar al mejor individuo
mejor=[];

%comenzar bucle
for i1=1:max_gen

if(i1>1)
%seleccion
[elegidos,scores_padre]=elegir_mejores(individuos_evaluados,scores);
end
%guardamos la generacion
arbol_genealogico=[arbol_genealogico; elegidos];
%guardamos al mejor
mejor=elegidos(:,1);
%informacion para la consola
fprintf('GENERACION');
disp(i1);
fprintf('mean:');
disp(mean(scores_padre));
[valor,indice]=max(scores_padre);
fprintf('best:');
disp(valor);

%disp('media:'+mean(scores_padre));
[porcentaje,n_individuo]=max(scores_padre);

%evolucion
descendencia=evolucionar(elegidos,i1);
%evaluar
scores_hijo=evaluar_generacion(descendencia,opciones,clutter,n_para_deteccion,fi_apuntamiento_deg,t_pulso);


%concatenar
individuos_evaluados=[elegidos descendencia];
scores=[scores_padre;scores_hijo];

end
save('copia_seguridad')
%%
fi_apuntamiento_deg=60;
clutter=generar_clutter(fi_apuntamiento_deg);
crom=decodificar_cromosoma(mejor,opciones,n_para_deteccion,t_pulso);
prfs=transpose(1./(crom*t_pulso));
[mapa,x,y]=visibilidad_conjunto_optima_algo(clutter,prfs,n_para_deteccion,fi_apuntamiento_deg);

figure;
mesh(x,y,mapa);
ylim([-500,2500]);
xlim([0,160]);
view(0,90);
xlabel("Distancia (km)",'Fontsize',22);
ylabel("Velocidad del blanco (km/h)",'Fontsize',22);
title('Mapa de visibilidad del modo de corto alcance 3-8','Fontsize',22);
porcentaje=evaluar_mapa(mapa);
porcentaje_cerca=evaluar_mapa_cerca(mapa);
porcentaje_lejos=evaluar_mapa_lejos(mapa);

%%
tiempo=0;
t_trans=160e3*2/3e8;
for i1=1:size(crom,1)
   tiempo=tiempo+128*crom(i1)*1e-7+t_trans; 
end
tiempo_barrido=120/3.9*tiempo;
 %informacion para la consola
fprintf('Secuencia:');
disp(prfs);
fprintf('Porcentaje:')
disp(porcentaje);
fprintf('Porcentaje lejos:')
disp(porcentaje_lejos);
fprintf('Porcentaje cerca:')
disp(porcentaje_cerca);
fprintf('Tiempo:');
disp(tiempo);
fprintf('Tiempo barrido completo:');
disp(tiempo_barrido);