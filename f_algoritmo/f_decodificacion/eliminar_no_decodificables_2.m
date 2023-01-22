function [set_pri]=eliminar_no_decodificables_2(set_pri,indice,resolucion)
%no decodificable, esta forma si elimina la correspondiente al indice
%parametros del radar
t_pulso=resolucion;
r_max=160e3;
prf_max=2*(2500/3.6)/0.03;%5000 para rapidos
minimo=2*r_max/3e8*(1/t_pulso);%lo multiplicamos por 10^8 para que este en el mismo orden de magnitud que las pris
%se elimina la escogida
choice=set_pri(indice);
set_pri(indice)=[];

for i1=1:size(set_pri,2)
  % if(i1>size(set_pri,2))
   %   break; 
   %end
   if((lcm(choice,set_pri(i1))<minimo)||(1/(t_pulso*gcd(choice,set_pri(i1)))<prf_max))
        
        set_pri(i1)=0;
        
   end
end
set_pri=transpose(nonzeros(set_pri));
