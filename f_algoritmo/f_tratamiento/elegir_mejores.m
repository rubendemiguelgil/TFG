function [elegidos,scores_elegidos]=elegir_mejores(individuos,scores)
%seleccion de los mejores y preservacion de sus puntuaciones
elegidos=zeros(size(individuos,1),ceil(size(individuos,2)/2));
scores_elegidos=zeros(ceil(size(individuos,2)/2),1);
scores_aux=scores;
for i1=1:size(elegidos,2)
   
    [valor,indice]=max(scores_aux);
    elegidos(:,i1)=individuos(:,indice);
    scores_elegidos(i1)=scores_aux(indice);
    scores_aux(indice)=0;%se pone a cero para que el maximo en la siguiente iteracion sea el segundo mejor
    
end