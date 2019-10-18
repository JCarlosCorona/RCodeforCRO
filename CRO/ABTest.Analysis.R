# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(tidyverse,
               ggplot2)

#Paso 1: Crear la Data (tomar solamente valores únicos)
test <- data.frame(
  VisitorID = runif(10000,1,25000)
)
d.test <- test %>% 
  distinct() %>% 
  mutate(Conversion = rbinom(nrow(.),1,.15)) %>% 
  mutate(PageViews = rnorm(nrow(.),4,1),
         VideoPlays = rnorm(nrow(.),7,2),
         Revenue =
           ifelse(
             Conversion == 1, rnorm(length(Conversion[which(Conversion == 1)]),5,1),ifelse(
               Conversion == 0,0,0
             )
           ))
#Paso 2: Ver la Data
View(d.test)

#Paso 3: Graficar la Data
hist(d.test$Revenue)

#Paso 4: Usar filtros
d.test %>% 
  filter(Conversion == 1)

d.test$Revenue[which(d.test$Conversion == 1)]

#Paso 5: Crear una nueva métrica que sea la suma de las otras
d.test <- d.test %>% 
  mutate(Engagement = VideoPlays + PageViews + Conversion * 5)
head(d.test)

#Paso 6: Correr un power analysis para las métricas que nos interesan.
  #Calcular el tamaño de la muestra para ambas variantes en el test.
power.prop.test(n = NULL, p1 = mean(d.test$Conversion * 5),
                p2 = mean(d.test$Conversion) * 0.05 + mean(d.test$Conversion),sig.level = 0.05, power = 0.8)$n*2

#Paso 7: Añadir los Valores de las Variantes
test.ready <- d.test %>% 
  mutate(seed = runif(nrow(.),1,2)) %>% 
  mutate(Variant =
           ifelse(seed > 1.5, "A", "B")) %>% 
  select(-seed)

#Paso 8: Dividir lada Data de A y B en grupos separados
A <-  test.ready[which(test.ready$Variant == "A"),]
B <-  test.ready[which(test.ready$Variant == "B"),]

#Paso 9: Correr el t.test en las métricas continuas y graficar las distribución.
t.test(A$Engagement, B$Engagement)

ggplot(data = test.ready, aes(x = test.ready$Engagement, col = Variant)) +
  geom_density()

#Paso 10: Correr un modelo lineal sobre la data en cualquier métrica.
model <- lm(data = test.ready, Revenue - Engagement)
summary(model)

#Paso 11: Correr un test Anova en la Data
anova(model)

#Paso 12: Configurar una regresión segmentada en Excel

#Paso 13: Importar a R
