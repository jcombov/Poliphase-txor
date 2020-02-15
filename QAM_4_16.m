function [modSig] = QAM_4_16(n_muestras,q)


if(q~=4 && q~=16)
    q=4; %Si q es un valor distinto de 4 o 16 funcionara en 4QAM
end


if(q==4) %00-> 1+j; 01->-1+j; 11-> -1-j; 10 ->1-j
k=log2(q); %numero de bits por símbolo

pares = reshape(n_muestras,length(n_muestras)/k,k);
a=ismember(pares, [0 0] , 'rows');
a=find(a==1);
pares(a)=1+i;
a=ismember(pares, [0 1] , 'rows');
a=find(a==1);
pares(a)= -1+i;
a=ismember(pares, [1 1] , 'rows');
a=find(a==1);
pares(a)= -1-i;
a=ismember(pares, [1 0] , 'rows');
a=find(a==1);
pares(a)= 1-i;

modSig= pares(:,1);
return
    
elseif(q==16)
k=log2(q); %numero de bits por símbolo

pares = reshape(n_muestras,length(n_muestras)/k,k);
pares_1=pares(:,1:2);
pares_2=pares(:,3:4);



a=ismember(pares_1, [0 0] , 'rows');
a=find(a==1);
pares_1(a)=-3;
a=ismember(pares_1, [0 1] , 'rows');
a=find(a==1);
pares_1(a)= -1;
a=ismember(pares_1, [1 1] , 'rows');
a=find(a==1);
pares_1(a)= 1;
a=ismember(pares_1, [1 0] , 'rows');
a=find(a==1);
pares_1(a)= 3;

a=ismember(pares_2, [0 0] , 'rows');
a=find(a==1);
pares_2(a)=-3*i;
a=ismember(pares_2, [0 1] , 'rows');
a=find(a==1);
pares_2(a)= -1*i;
a=ismember(pares_2, [1 1] , 'rows');
a=find(a==1);
pares_2(a)= 1*i;
a=ismember(pares_2, [1 0] , 'rows');
a=find(a==1);
pares_2(a)= 3*i;



modSig= pares_1(:,1) + pares_2(:,1);
return

end

