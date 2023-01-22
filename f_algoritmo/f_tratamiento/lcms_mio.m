function output = lcms_mio(numberArray)
aux=1;
for i1=1:size(numberArray,2)
    aux=lcm(aux,numberArray(i1));
end
output=aux;