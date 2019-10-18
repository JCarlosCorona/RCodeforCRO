# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(tidyverse,
               xml2,
               rvest)

#Asignamos la url
url <- "https://www.amazon.com.mx/s?k=google+pixel&rh=n%3A9687460011&__mk_es_MX=%C3%85M%C3%85%C5%BD%C3%95%C3%91&ref=nb_sb_noss"

#Obtenemos código html de la página web
pagina_web <- read_html(url)

#Asignamos la clase
css_producto <- "a.a-link-normal.s-access-detail-page.s-color-twister-title-link.a-text-normal"

#Obtenemos el código html que contiene el nombre del producto
producto_html <- html_nodes(pagina_web,css_producto)
producto_texto <- html_text(producto_html)

#mostramos los datos, al final presionar enter
producto_texto

#clase css del producto
css_precio <- "span.a-size-base.a-color-price.s-price.a-text-bold"
#obtenemos el contenido de la clase en código html
precio_html <- html_nodes(pagina_web,css_precio)
#limpiamos el código para obtener el texto
precio_texto <- html_text(precio_html)

#Eliminamos el signo de peso
precio_limpio <- gsub("$","",precio_texto)
#Eliminamos la coma
precio_limpio <- gsub(",","",precio_limpio)
#Transformamos a numérico 
precio_numerico <- as.numeric(precio_limpio)

#Unimos los datos
productos <- data.frame(Producto = producto_texto, Precio = precio_numerico)
#Para mostrar la gráfica por precio
barplot(precio_numerico)

