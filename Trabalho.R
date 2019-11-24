#-- Dependencias de bibliotecas

#install.packages("pingr")
library(pingr)

#install.packages("iptools")
library(iptools)

#install.packages("IPtoCountry")
library(IPtoCountry)

#install.packages("sqldf")
library("sqldf")



#-- Funcoes criadas
scanAllPorts = function (ip,portMin,portMax){
  #TO DO - funcoes de paralelizacao
  
  tabela = NULL
  
  #Existem 65.536 portas - 0 a 65535 - No r e 1 a 655365 
  for (numeroPorta in portMin:portMax){
    
    resp = ping_port(ip,port = numeroPorta,count=1)
    if(is.na(resp))
      resp = "Closed"
    else
      resp="Open"
    
    
    linhaTabela = c(ip,numeroPorta, resp)
    tabela = rbind(tabela, linhaTabela)
  }
  
  
  colnames(tabela) = c("Ip","Porta","Status")
  #rownames(tabela) = c("")
  return (tabela)
}
scanAllIps = function(IPs,portMin,portMax) {
  
  tabelaComIps = NULL
  
  for (Ip in IPs) {
    tabelaComUmIp = scanAllPorts(Ip,portMin,portMax)
    tabelaComIps = rbind(tabelaComIps,tabelaComUmIp)
  }
  return (tabelaComIps)
}

# Funcoes que obtem quantidade de dados reduzidos para testes
obterTabelaIpsComStatusPortas = function(teste){

  if(teste){
    vetor = IPs[1:4]
    portMin=79
    portMax=81
  }
  else{
    vetor = IPs
    portMin=1
    portMax=655365
  }
  #Tabela com o status de cada porta para cada ip
  tabelaIpsPortas = scanAllIps(vetor,portMin,portMax)
  return(tabelaIpsPortas)
}



#-- Fluxo Principal

#A variavel teste deve ser setada para false para se obter dados reais.
#Ela setada como true obtem pequenas amostras para testes de todas as informacoes
teste=TRUE

#NumMaxIps ou e 200 ou e 400
numMaxIps = ifelse(teste==TRUE, 200, 400)

# Ips que utilizaremos
IPs = IP_generator(numMaxIps) #function of library IPtoCountry

#Identificacao do pais e regiao de cada IP 
IpsPaisesRegiao = IP_location(IPs) #function of library IPtoCountry

#Tabela com os status de cada porta por IP
tabelaIpsPortas = as.data.frame(obterTabelaIpsComStatusPortas(teste))

Funcionalidade1 = sqldf("select country as pais, count(*) as quantidadeIPs from IpsPaisesRegiao group by country") 
Funcionalidade2 = sqldf("Select count(distinct(Ip)) as NumeroDeIPsComPortaAberta from tabelaIpsPortas where Status = 'Open'")
Funcionalidade3 = sqldf("Select Porta, count(*) as NumeroDeIPs from tabelaIpsPortas where Status = 'Open' group by Porta")
Funcionalidade4 = sqldf("Select * from tabelaIpsPortas")
Funcionalidade5 = sqldf("select country as pais, region as regiao, count(*) as quantidadeIPs from IpsPaisesRegiao group by country, region") 
