#-- Dependencias de bibliotecas
install.packages("pingr")
library(pingr)

install.packages("iptools")
library(iptools)

install.packages("IPtoCountry")
library(IPtoCountry)

install.packages("sqldf")
library("sqldf")

install.packages("plyr")
library("plyr")
#https://www.curso-r.com/blog/2017-03-14-parallel/


#-- Funcoes criadas
scanPort = function(Porta){
  Status = ping_port(IP_Global,port = Porta,count=1)
  
  if(is.na(Status))
    Status = "Closed"
  else
    Status="Open"
  
  #Cria 3 colunas para cada linha - IP | Porta | Status
  linhaTabela = c(IP_Global,Porta, Status)
  
  #Adiciona em uma matriz
  tabela <<- rbind(tabela, linhaTabela)
  
  colnames(tabela) <<- c("Ip","Porta","Status")
}
scanPortsInRanged = function (IP){
  
  IP_Global <<- IP
  
  #Existem 65.536 portas - 0 a 65535 - No R e 1 a 655365
  ports = portMin:portMax
  
  #Faça paralelo aqui embaixo @Jonathan
  system.time({
    #Lista com o status de cada porta para cada ip em uma posição
    plyr::llply(ports, scanPort,.progress = progress_text(char = "."))
  })
  
  return (tabela)
}
scanAllIPsAndAllPorts = function(IPs) {

#   Tentativa de fazer Paralelo
#   system.time({
#     #Lista com o status de cada porta para cada ip em uma posição
#     plyr::llply(IPs, scanPortsInRanged,.progress = progress_text(char = "."),.parallel = TRUE)
#   })

# Sequencial
  for (IP in IPs) {
    scanPortsInRanged(IP)
  }
}

# Funções auxiliares
valoresGlobais= function(teste){
  #Vetor de IPs ou e completo ou e reduzido
  if(teste==TRUE){
    vetorDeIPs <<- IPs[1:4];
  }else {
    vetorDeIPs <<- IPs;
  }
  
  portMin <<- ifelse(teste==TRUE, 75, 80) 
  
  portMax <<- ifelse(teste==TRUE, 81, 80) 
  
  tabela <<- NULL
  
}

#-- Fluxo Principal
teste = FALSE

# Ips que utilizaremos
IPs = IP_generator(200) #function of library IPtoCountry

#Identificacao do pais e regiao de cada IP 
IpsPaisesRegiao = IP_location(IPs) #function of library IPtoCountry

#Alteracao dos valores para teste ou producao
valoresGlobais(teste)
scanAllIPsAndAllPorts(vetorDeIPs)

#Tabela com os status de cada porta por IP
tabelaIpsPortas = as.data.frame(tabela)

Funcionalidade1 = sqldf("select country as pais, count(*) as quantidadeIPs from IpsPaisesRegiao group by country") 
Funcionalidade2 = sqldf("Select count(distinct(Ip)) as NumeroDeIPsComPortaAberta from tabelaIpsPortas where Status = 'Open'")
Funcionalidade3 = sqldf("Select Porta, count(*) as NumeroDeIPs from tabelaIpsPortas where Status = 'Open' group by Porta")
Funcionalidade4 = sqldf("Select * from tabelaIpsPortas")
Funcionalidade5 = sqldf("select country as pais, region as regiao, count(*) as quantidadeIPs from IpsPaisesRegiao group by country, region") 

#Escreve nos arquivos os dados
write.table(IPs, file='IPs.csv', sep=';', dec=',', row.names=FALSE)
write.table(IpsPaisesRegiao, file='IpsPaisesRegiao.csv', sep=';', dec=',', row.names=FALSE)
write.table(tabelaIpsPortas, file='IpsPortas.csv', sep=';', dec=',', row.names=FALSE)

#Escreve nos arquivos as respostas
write.table(Funcionalidade1, file='Resposta1.csv', sep=';', dec=',', row.names=FALSE)
write.table(Funcionalidade2, file='Resposta2.csv', sep=';', dec=',', row.names=FALSE)
write.table(Funcionalidade3, file='Resposta3.csv', sep=';', dec=',', row.names=FALSE)
write.table(Funcionalidade4, file='Resposta4.csv', sep=';', dec=',', row.names=FALSE)
write.table(Funcionalidade5, file='Resposta5.csv', sep=';', dec=',', row.names=FALSE)