function[descendencia]=evolucionar(elegidos,n_generacion)
%esta funcion devuelve los 50 nuevos individuos de la siguiente generacion


%cruce
hijos=zeros(size(elegidos,1),size(elegidos,2));
%copiamos los elegidos para aparearlos
parejas=elegidos;

%escogemos las parejas al azar con una probabilidad del 70 %
for i1=1:size(elegidos,2)
    %escogemos al individuo
    individuo=elegidos(:,i1);
    if(rand>0.3)%0.7 de probabilidad de cruce
        
        %indice de la pareja aleatorio
        indice=ceil(rand*size(parejas,2));
        %revisamos que no se aparee con sigo mismo
        while(indice==i1)
            indice=ceil(rand*size(parejas,2));   
        end
        %escogemos la pareja
        pareja=parejas(:,indice);
        %creamos al hijo
        hijo=[];
        %para cada gen
        for j1=1:size(elegidos,1)
            %generamos un numero aleatorio necesario para obtener la descendencia (se usan numeros reales en vez de strings binarios)
            r_al=rand;
            while((individuo(j1)+(1.5*r_al-0.25)*(pareja(j1)-individuo(j1))<=0)||(individuo(j1)+(1.5*r_al-0.25).*(pareja(j1)-individuo(j1))>=1))
            r_al=rand;%si se sale de los limites escogemos otro numero diferente
            end 

            %cruzamos los individuos de acuerdo con la formula del articulo alabaster
            hijo=[hijo individuo(j1)+(1.5*r_al-0.25)*(pareja(j1)-individuo(j1))];
             
        
        end
           
       
        
        
        hijos(:,i1)=hijo;
        
    else %si no hay cruce se mantiene al individuo
        
        hijos(:,i1)=individuo;
        
    end
end

%mutacion (añadimos un num aleatorio a cada gen segun una dist gaussiana)

for i1=1:size(hijos,2)
    for j1=1:size(hijos,1)
        r_al=randn;
        %revisamos que no pase los extremos
        while ((hijos(j1,i1)+(1/8)*r_al*(0.9^n_generacion)<=0)||(hijos(j1,i1)+(1/8)*(0.9^n_generacion)*r_al>=1))
           r_al=randn; %si se sale de los limites cambiamos el numero aleatorio
        end
        hijos(j1,i1)=hijos(j1,i1)+(1/8)*(0.9^n_generacion)*r_al;
        
        
    end
end

descendencia=hijos;

