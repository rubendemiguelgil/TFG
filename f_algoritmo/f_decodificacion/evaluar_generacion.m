function[scores]=evaluar_generacion(generacion,opciones,clutter,n_para_deteccion,fi_apuntamiento_deg,resolucion)
%poblacion_deco=[];
 %poblacion_deco_limpia=[];
 n_individuos=size(generacion,2);
 scores=zeros(n_individuos,1);
 for i1=1:n_individuos
    cromosoma=decodificar_cromosoma(generacion(:,i1),opciones,n_para_deteccion,resolucion);
    %poblacion_deco=[poblacion_deco cromosoma];
    %poblacion_deco_limpia=[poblacion_deco_limpia unique(cromosoma)];%comprueba que no haya repeticiones
    scores(i1)=evaluar(cromosoma,clutter,n_para_deteccion,fi_apuntamiento_deg,resolucion);
 end