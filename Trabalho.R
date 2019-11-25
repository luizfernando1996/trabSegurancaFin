#-- Dependencias de bibliotecas


dependencias = function(){
  #install.packages("pingr")
  library(pingr)

  #install.packages("iptools")
  library(iptools)
  
  #install.packages("IPtoCountry")
  library(IPtoCountry)
  
  #install.packages("sqldf")
  library("sqldf")
  
  #install.packages("plyr")
  library("plyr")
  #https://www.curso-r.com/blog/2017-03-14-parallel/
  
  #install.packages("foreach")
  library(foreach)
  
  #install.packages("doParallel")
  library(doParallel)
  
  
}

#-- Funcoes criadas
scanPort = function(Porta){
  library(pingr)
  
 
  
  Status = ping_port(IP_Global,port = Porta,count=1)
  
  if(is.na(Status))
    Status = "Closed"
  else
    Status="Open"
  
  #Cria 3 colunas para cada linha - IP | Porta | Status
  # linhaTabela = paste(IP_Global,"," ,Porta,",", Status)
  
  #Adiciona em uma matriz
  #tabela <<- rbind(tabela, linhaTabela)
  
  #colnames(tabela) <<- c("Ip","Porta","Status")
  
  #write(linhaTabela, file="out.csv", append=T)
  
  return(c(IP_Global, Porta, Status))
}
scanPortsInRanged = function (IP){
  
  IP_Global <<- IP
  
  #Existem 65.536 portas - 0 a 65535 - No R e 1 a 655365
  ports = portMin:portMax
  
  #Faça paralelo aqui embaixo @Jonathan
 
   # system.time({
   #   #Lista com o status de cada porta para cada ip em uma posição
   #   plyr::llply(ports, scanPort,.progress = progress_text(char = "."))
   # 
   # })

  
  # for (port in ports) {
  #    
  #    scanPort(port)
  #    
  # }
  
  registerDoParallel(8)  # use multicore, set to the number of our cores
  print("Antes paralelo")
  output <<- foreach (i=1:ports, .export = ls (envir = globalenv()), .combine = 'rbind') %dopar% {


    scanPort(i)

  }

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
    print("Varrendo IP")
    
    scanPortsInRanged(IP)
  }
}

# Funções auxiliares
valoresGlobais= function(teste){
  #Vetor de IPs ou e completo ou e reduzido
  if(teste==TRUE){
    vetorDeIPs <<- IPs[1:200];
  }else {
    vetorDeIPs <<- IPs;
  }
  
  portMin <<- ifelse(teste==TRUE, 75, 80) 
  
  portMax <<- ifelse(teste==TRUE, 81, 80) 
  
 
  
  tabela <<- data.frame(IP=character(),
                        Porta=character(),
                        Status=character(),
                        stringsAsFactors=FALSE)
  
}

#-- Fluxo Principal
teste = TRUE

# Ips que utilizaremos
IPs = IP_generator(1) #function of library IPtoCountry

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