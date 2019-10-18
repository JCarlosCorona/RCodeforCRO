# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               tidyverse)

ga_auth()
1

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID requerido
cuentas <- ga.cuentas %>%
  select(c(contains("Name"),contains("Id"))) %>% 
  filter(grepl("soriana",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
n <- 1
a.id <- cuentas$accountId[n]
w.id <- cuentas$webPropertyId[n]
p.id <- cuentas$viewId[n]

ga.goals <- ga_goal_list(accountId = a.id  ,webPropertyId = w.id ,profileId = p.id)

goals <- ga.goals %>%
  select(accountId,webPropertyId,profileId,id,name,type,active)
goals
