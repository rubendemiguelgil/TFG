function [set_pri]=eliminar_no_decodificables_3(set_pri,elegidas,n_para_deteccion,resolucion)
%no decodificable, esta verison no elimina la correspondiente al indice,
%pues este no se uliliza, es necesario eliminar las elegidas de las
%opciones antes de llamar a la funcion

%parametros del radar
t_pulso=resolucion;
r_max=160e3;
minimo=2*r_max/3e8*(1/resolucion);%lo multiplicamos por 10^8 para que este en el mismo orden de magnitud que las pris
prf_max=2*(2500/3.6)/0.03;%5000 para rapidos



permutaciones=combnk(elegidas,n_para_deteccion-1);

for i1=1:size(permutaciones,1)
 for j1=1:size(set_pri,2)
  
   if((lcms_mio([permutaciones(i1,:) set_pri(j1)])<minimo)||(1/(t_pulso*gcd_mio([permutaciones(i1,:) set_pri(j1)]))<prf_max))%comprobamos que las pri sean decodificalble en distancia (1ª condicion) y doppler (2ª condicion)
        
        set_pri(j1)=0;
        
   end
 end
    
    
set_pri=transpose(nonzeros(set_pri));

end



