function [individuos] = generador_individuos (n_individuos,n_prf_set)
individuos=[];
for i1=1:n_individuos
     cromosoma=[];
     
     for j1=1:n_prf_set
        gen=rand;
        cromosoma=[cromosoma gen];
     end
         
     individuos=[individuos transpose(cromosoma)];
   
     
 end