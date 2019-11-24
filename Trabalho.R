#-- Dependencias de bibliotecas

#ping r -- Instale essa biblioteca para o comando abaixo poder funcionar
#Verifique se um computador remoto está ligado. Ele pode simplesmente 
#chamar o comando ping do sistema ou verificar uma porta TCP especificada.
install.packages("pingr")
library(pingr)

#iptools -- Instale essa biblioteca para o comando abaixo poder funcionar
#iptoolsé um pacote para tornar os endereços IP convenientes para lidar, analisar e validar.
install.packages("iptools")
library(iptools)

#IPtoCountry -- Instale essa biblioteca para o comando abaixo poder funcionar
#Ferramentas para identificar as origens dos endereços IP. Inclui funções para
#converter endereços IP em nomes de países, detalhes de localização
#(região, cidade, CEP, latitude, longitude), códigos IP, valores binários, 
#além de uma função para plotar locais IP em um mapa do mundo.
install.packages("IPtoCountry")
library(IPtoCountry)

install.packages("sqldf")
library("sqldf")

install.packages("dplyr")

#-- Funcionalidades

# Intervalo de ips que utilizaremos
IPs = IP_generator(200) #IPtoCountry.pdf


#Funcionalidade 1 - quantidade de IPs escaneados por país
IpsPaises = IP_location(IPs) #IPtoCountry.pdf

Funcionalidade1 <- sqldf("select country as pais, count(*) as quantidadeIPs from IpsPaises group by country") 

Funcionalidade5 <- sqldf("select country as pais, region as regiao, count(*) as quantidadeIPs from IpsPaises group by country, region") 

#Link: https://cran.r-project.org/web/packages/IPtoCountry/IPtoCountry.pdf


