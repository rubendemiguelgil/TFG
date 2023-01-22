function [mapa_conjunto,array_prf_ajustado,x_ref,y_ref] = visibilidad_conjunto_optima(clutter,prf_array,n_para_deteccion,fi_apuntamiento_deg)
%esta funcion requiere que el clutter se le pase como parametro
n_prf=size(prf_array,2);
array_prf_ajustado=[];
for i1=1:n_prf
   [mapa,prf_a,x,y]=mapa_visibilidad(clutter,prf_array(i1),fi_apuntamiento_deg); 
   eval(sprintf("mapa%d=mapa;",i1));
   eval(sprintf("prf_%d_a=prf_a;",i1));
   x_ref=x;%x e y son iguales para todas las prfs (rejilla fija para que sea mas facil comparar visibilidades), por lo que no importa los de que prf guardemos
   y_ref=y;%""
   array_prf_ajustado=[array_prf_ajustado eval(sprintf("prf_%d_a",i1))];
end


%array visibilidad
array_visibilidad=[];
for i1=1:n_prf
array_visibilidad=[array_visibilidad eval("mapa"+i1)];%concatenamos los mapas en distancia
end

%mapa visibilidad de varias prf
visibilidad_conjunto=zeros(size(array_visibilidad,1),size(array_visibilidad,2)/n_prf);%dividimos entre n_prf porque hemos concatenado n_prf matrices
%variable contador de deteccion
n_detecciones=0;
for i1=1:size(array_visibilidad,2)/n_prf
    for j1=1:size(array_visibilidad,1)
        for z1=1:n_prf
           
            if(array_visibilidad(j1,(z1-1)*size(array_visibilidad,2)/n_prf+i1)==1)%miramos el mismo punto en las diferentes prf
                n_detecciones=n_detecciones+1;
            end
            if(n_detecciones>=n_para_deteccion)
                visibilidad_conjunto(j1,i1)=1; 
            end
            
        end
        n_detecciones=0;%reseteamos el numero de detecciones cada vez que nos movemos de punto
    end
end
mapa_conjunto=visibilidad_conjunto;