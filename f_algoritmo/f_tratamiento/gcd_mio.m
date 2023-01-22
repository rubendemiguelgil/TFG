function output = gcd_mio(numberArray)
aux=0;
for i1=1:size(numberArray,2)
    aux=gcd(aux,numberArray(i1));
end
output=aux;