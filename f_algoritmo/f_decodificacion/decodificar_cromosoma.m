function [r_bins_set] = decodificar_cromosoma(cromosoma,opciones,n_para_deteccion,resolucion)
if(n_para_deteccion==2)
    %var auxiliares
    opciones_aux=transpose(opciones);
    r_bins_set=zeros(size(cromosoma,1),1);
for i1=1:size(cromosoma,1)
   
    indice=ceil(cromosoma(i1)*size(opciones_aux,1));
    r_bins_set(i1)=opciones_aux(indice);
    opciones_aux=transpose(eliminar_no_decodificables_2(opciones_aux,indice,resolucion));
    
end
r_bins_set=sort(r_bins_set,'descend');


elseif(n_para_deteccion>2)
   %var auxiliares
   opciones_aux=transpose(opciones);
   elegidas=[];
   r_bins_set=zeros(size(cromosoma,1),1); 
   %la primera se escoge fuera del bucle porque no se necesita comprobacion hasta el tercer n de r_bins 
    %indice=ceil(cromosoma(1)*size(opciones_aux,1));
    %r_bins_set(1)=opciones_aux(indice);
    %opciones_aux(indice)=[];
    %elegidas=r_bins_set(1);
   %la primera y segunda se escogen sin tener en cuenta la decodificacion
   for i1=1:size(cromosoma,1)
    indice=ceil(cromosoma(i1)*size(opciones_aux,1));
    r_bins_set(i1)=opciones_aux(indice);
    opciones_aux(indice)=[];
    elegidas=[elegidas r_bins_set(i1)];
    if(i1==size(cromosoma,1))
    break;
    end
    opciones_aux=transpose(eliminar_no_decodificables_3(opciones_aux,elegidas,n_para_deteccion,resolucion));
   
   end
r_bins_set=sort(r_bins_set,'descend');    
    
end
















