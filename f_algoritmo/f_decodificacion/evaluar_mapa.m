function [porcentaje_visibilidad] = evaluar_mapa(mapa_visibilidad)

total=size(mapa_visibilidad,2)*size(mapa_visibilidad,1);
detecciones=0;
for i1=1:size(mapa_visibilidad,2)
    for j1=1:size(mapa_visibilidad,1)
     detecciones=detecciones+mapa_visibilidad(j1,i1);   
    end
end

porcentaje_visibilidad=(detecciones/total)*100;