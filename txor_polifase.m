%% 
clc, close all, clear

f=10e6; %frecuencia de simbolo
fc=10e7; %frecuencia central
Ltx=2; %numero de ramas
Mtx=3; %factor máximo de sobremuestreo
fs= f* Mtx * Ltx; %frecuencia de muestreo
Ts=1/fs;
T=1/f; %Período de símbolo
span = 10; % Longitud del filtro, span * nSamp
Q=16;
n = 10000; % número de bits a transmitir
nSamp = Ltx*Mtx; % Factor de sobremuestreo
rolloff = 0.5; % Rolloff factor
n_senales=10; %numero de las primeras señales a representar

n_muestras= -span:1/nSamp: span-1/nSamp;

txfilter=ifft(sqrt(abs(fft(rcosdesign(rolloff,span*2, Ltx*Mtx)))));

txfilter= [txfilter(round(length(txfilter)/2)+1:end) txfilter(1:round(length(txfilter)/2)-1)];

figure, stem(txfilter)
title('Filtro txor')

x = round(rand(1,n));
modSig= QAM_4_16(x,Q)';
modSig2=modSig;

scatterplot(modSig)
b=[1 zeros(1, Mtx*Ltx-1)];
 
modSig= kron(modSig, b);

txmitir_real= real(modSig'*txfilter);
txmitir_imag= imag(modSig'*txfilter);
figure

for i=1: n_senales*Mtx*Ltx
    A=zeros(1, length(0:T/(Mtx*Ltx):(i-1)*T));
    representacion=horzcat(A,txmitir_real(i,:));
    representacion_i=horzcat(A,txmitir_imag(i,:));
    subplot(211)
    stem(representacion)
    title('Parte real a transmitir del numero de señales introducidas a representar (monofase)')
    hold on;
    subplot(212)
    stem(representacion_i)
    title('Parte imaginaria a transmitir del numero de señales introducidas a representar(monofase)')
    hold on;
    
    
end

longitud= length(representacion);

%% 

%Ahora dividiremos los coeficientes del filtro
figure
for j=1:Ltx %cada filtro de cada rama puede tener un factor de sobremuestreo de M
          %con L ramas conseguimos la tasa de sobremuestreo de L*M
subplot(ceil(Ltx/2),2,j)  
Variable=num2str(j-1);
texto_titulo='coeficientes de la rama ';
titulo=strcat(texto_titulo,Variable);
filtro_rama(j,:)=txfilter(j:Ltx:end); %Asignamos los coeficientes del filtro a cada rama
stem(filtro_rama(j,:)), hold on
title(titulo)
end

hold off;

filtro_eq=zeros(length(modSig), length(n_muestras)); 
b=[1 zeros(1, Mtx-1)];

txmitir_rama= zeros(length(modSig), length(filtro_rama(1,:)));

modSig2= kron(modSig2, b);


for k=1: Ltx 
  
txmitir_rama2 =modSig2'*filtro_rama(k,:);   %a cada rama le pasamos todos los simbolos con un upsampling por Mtx

for l=1:Mtx*Ltx:length(txmitir_rama2)

txmitir_rama(l,:)=txmitir_rama2(ceil(l/Ltx),:);  %hacemos un upsampling de L

end

for j=1: length(n_muestras)/Ltx
    
    filtro_eq(:,j*Ltx + k-Ltx)= txmitir_rama(:,j); %retardamos cada rama y almacenamos en un vector que será igual al filtro txor con una sola rama

end

end


filtro_eq_real= real(filtro_eq);
filtro_eq_imag=imag(filtro_eq);

figure
title('Salida txor polifase a representar')

sumatodo_r=zeros(1, longitud);
sumatodo_i=sumatodo_r;

for i=1: n_senales*Mtx*Ltx
    A=zeros(1, length(0:T/(Mtx*Ltx):(i-1)*T));
    
    representacion=horzcat(A,filtro_eq_real(i,:));
    B=zeros(1, length(sumatodo_r)-length(representacion));
    representacion=horzcat(representacion,B);
    representacion_i=horzcat(A,filtro_eq_imag(i,:));
    representacion_i=horzcat(representacion_i,B);
    subplot(211)
    stem(representacion)
    title('Parte real a transmitir del numero de señales introducidas a representar(polifase)')
    hold on;
    subplot(212)
    stem(representacion_i)
    title('Parte imaginaria a transmitir del numero de señales introducidas a representar(polifase)')
    hold on;
    
    sumatodo_r= sumatodo_r + representacion;
    sumatodo_i= sumatodo_i + representacion_i;
    
end


n=0:1:length(sumatodo_r)-1;
salida_mod_r= sumatodo_r .* cos (fc*2*pi*n*Ts);
salida_mod_i= sumatodo_i .* sin (fc*2*pi*n*Ts); %No multiplico por j y despues lo sumo porque tomé desde el principio la parte imaginaria

salida_mod=salida_mod_r+salida_mod_i;

figure,plot(salida_mod)
title('Salida del modulador del numero de señales introducidas a representar')

