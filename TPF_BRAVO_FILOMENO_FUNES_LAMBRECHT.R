#######################################################################
#           MÉTODOS DE ANÁLISIS MULTIVARIADO 26/10/2023               #
#                                                                     #
#                           TRABAJO FINAL                             # 
#                                                                     #
#                           1ER ENTREGA                               #
#                                                                     #
#             GRUPO N°3: FUNES-LAMBRECHT-FILOMENO-BRAVO               #
#                                                                     #
#######################################################################


#Seteamos el lugar de trabajo
setwd('D:/MAESTRÍA/TALLER DE ANALISIS MULTIVARIADO/1er entrega')


#Instalamos los paquetes y llamamos a las librerías a utilizar


library(gmodels) 
library(ca) 
library(FactoMineR) 
library(ggplot2) 
library(factoextra) 
library(gplots) 
library(graphics) 
library(readxl)
library(NbClust)
library(cluster)
library(tidyr)

#Se carga la base de datos

data <- read_excel("Base de Datos Grupo 3.xlsx")
data

#Se realiza una breve descripción de la base

summary(data)
names(data)


#Guardamos el data completo y luego sacamos las variables que no vamos a utilizar 

# Se busca realizar una segmentación de sucursales por desempeño, para lo cual se van a considerar las siguientes variables:
  # $ Ventas, $ Margen, $ Mermas, Costo laboral, $Buffet y $Donaciones
# Se quiere agrupar las sucursales de acuerdo a características similares en cuento a rendimiento y eficiencia
# Este análisis corresponde al pundo de partida, de un proceso para detectar áreas de mejora. Establecer
# puntos en los cuales continuar investigando, para llegar a conclusiones aplicables o propuestas de mejora.


# Alcance: 
  # No se va a realizar un proceso iterativo para incluir, excluir o modificar variables luego de
  # obtenidos los primeros resultados satisfactorios.
  # Como el objetivo es educativo, se busca demostrar la utilización de diversos métodos, no así
    # la búsqueda de conclusiones aplicables directamente al negocio.
  # No se van a realizar otros análisis, a las mismas variables u otras, para 


# Se limpia la base de datos para trabajar solo con las variables de interés

df = data[c(9, 10, 12, 14, 15, 17)]
dim(df)
head(df, 3)

# Se hace un análisis de correlación de las variables

View(cor(df))

# Se aprecia que existe una gran correlación lineal entre la mayoría de las variables
# Se grafican la relación entre algunos pares de variables, donde se aprecia dicha relación

scatter.smooth(df$`$ Venta s/IVA`, df$`$ Margen AM`)
scatter.smooth(df$`$ Venta s/IVA`, df$`$ Donacion Mercaderia`)
scatter.smooth(df$`$ Margen AM`, df$`$ Mermas`)
scatter.smooth(df$`$ Margen AM`, df$`$Bufet`)
scatter.smooth(df$`$Bufet`, df$`Costo Laboral (Sin seguridad y Limpieza)`)
scatter.smooth(df$`$Bufet`, df$`$ Donacion Mercaderia`)
scatter.smooth(df$`Costo Laboral (Sin seguridad y Limpieza)`, df$`$ Venta s/IVA`)
scatter.smooth(df$`Costo Laboral (Sin seguridad y Limpieza)`, df$`$ Margen AM`)

# Se decide independizar la performance de cada sucursal de su tamaño, para lo cual se van a analizar las variables
# en relación a las ventas, de esta manera se puede agrupar las sucursales realmente por su desempeño.
# Entonces se crean nuevas variables:

df['margen_%'] = round(df$`$ Margen AM` / df$`$ Venta s/IVA` * 100, 2)
df['mermas_%'] = round(df$`$ Mermas` / df$`$ Venta s/IVA` * 100, 2)
df['costo_laboral_%'] = round(df$`Costo Laboral (Sin seguridad y Limpieza)` / df$`$ Venta s/IVA` * 100, 2)
df['buffet_%'] = round(df$`$Bufet` / df$`$ Venta s/IVA` * 100, 2)
df['donaciones_%'] = round(df$`$ Donacion Mercaderia` / df$`$ Venta s/IVA` * 100, 2)

# Se seleccionan para continuar la variable ventas en adición a las últimas variables creadas

dfp = df[c(1,7,8,9,10,11)] # la 'p' por proporción
names(dfp)

# Se visualiza la matriz de correlaciones para las nuevas variables 

View(cor(dfp))

# Se aprecia la pérdida de correlación con respecto a las variables originales. A continuación se grafican
# algunos pares de variables para visualizarlo.

scatter.smooth(dfp$`$ Venta s/IVA`, dfp$`margen_%`)
scatter.smooth(dfp$`$ Venta s/IVA`, dfp$`donaciones_%`)
scatter.smooth(dfp$`margen_%`, dfp$`mermas_%`)
scatter.smooth(dfp$`margen_%`, dfp$`buffet_%`)
scatter.smooth(dfp$`buffet_%`, dfp$`costo_laboral_%`)
scatter.smooth(dfp$`buffet_%`, dfp$`donaciones_%`)
scatter.smooth(dfp$`costo_laboral_%`, dfp$`$ Venta s/IVA`)
scatter.smooth(dfp$`costo_laboral_%`, dfp$`margen_%`)


# Ahora se procede a normalizar o escalar las variables,principalmente debido a que la variable ventas
# quedó en valores absolutos, mientras que el resto de variables quedaron expresadas como proporciones

dfp_norm = scale(dfp)

# Se analizan los outlier, para lo cual se va a utilizar la distancia de mahalanobis

medias = colMeans(dfp_norm)
covarianza = cov(dfp_norm)

D2 = mahalanobis(x=dfp_norm, center = medias, cov = covarianza, inverted = FALSE)
D2
pchisq(D2, df=6, lower.tail = FALSE) # p-valores de acuerdo a la distribución chi cuadrado
qchisq(.99, df=6) # Valor crítico de D a partir del cual se lo considera outliers (rechazo de H0)
                  # con un nivel de significancia del 99%
sum(D2>16.81189) # Se busca saber la cantidad de valores que exceden el crítico. Son 5
out = which(D2>16.81189) # se encuentran las posiciones de los outliers
out
D2[D2>16.81189] # Se encuentran los valores 

# Estos valores en una primera instancia se van a separar de la base de datos, para evitar que distorcionen
# el agrupamiento. En una instancia posterior se los analizará con mayor detalle para evaluar cómo se procede
# con ellos.

# la nueva base de datos es la siguiente:

dfp_norm1 = dfp_norm[-out,]

dim(dfp_norm1) # se verifica que hayan sido quitado los registros

data_out = data[-out,] # se quita los mismos registros en la base original
dim(data_out)

# Para proceder con el análisis de cluster se calcula la matriz de distancias. Se va a trabajar con
# distancia Euclidea.

dist = dist(dfp_norm1, method = 'euclidean')
dist

# se visualiza las distancias entre variables con escalas de colores. Sirve para tener una primera impresión
# se si existen grupos de acuerdo a sus distancias
fviz_dist(dist, gradient = list(low = 'blue',mid = 'white', high = 'red' ))

# Se realiza el análisis de cluster, con 4 métodos jerárquicos
hc_cer = hclust(dist, method = 'single')
hc_lej = hclust(dist, method = 'complete')
hc_ward = hclust(dist, method = 'ward.D')
hc_prom = hclust(dist, method = 'average')

# Se grafica cada dendograma
plot(as.dendrogram(hc_cer), main = "single")
plot(as.dendrogram(hc_lej), main = "complete")
plot(as.dendrogram(hc_ward), main = "ward.D")
plot(as.dendrogram(hc_prom), main = "average")


# Se utiliza el método de los índices para determinar cuál es la cantidad de cluster más recomendada
ncluster = NbClust(dfp_norm1, distance = 'euclidean', min.nc = 2, max.nc = 15, , method = "ward.D2", index = "alllong")

# La cantidad óptima de clusters es: 4




# Se realiza el mismo cálculo, pero considerando la base de datos que no excluye los outliers

#ncluster_o = NbClust(dfp_norm, distance = 'euclidean', min.nc = 2, max.nc = 15, , method = "ward.D2", index = "alllong")

# el número óptimo de clusters es 3




# A continuación se muestran diferentes dendogramas con el agrupamiento de los cluster de acuerdo al óptimo para el método de Ward.
fviz_dend(x = hc_ward, cex = 0.8, lwd = 0.8, k = 4,
          
          
          # OR JCO fill color for rectangles
          k_colors = c("jco"),
          rect = TRUE, 
          rect_border = "jco", 
          rect_fill = TRUE)

fviz_dend(hc_ward, k = 4, # Cortar en cuatro grupos
          cex = 0.5, # tamaño de la etiqueta
          k_colors = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
          color_labels_by_k = TRUE, # etiquetas de color por grupos
          rect = TRUE # agregar rectángulo alrededor de los grupos
)



# Partiendo de la cantidad óptima de cluster recomendado en el paso anterior se procede a realizar un
# análisis no jerárquico, a través del método K-means.
# HABRÍA QUE VER DE CALCULAR LOS CENTROIDES PARA EL MÉTODO DE WARD PARA 4 CLUSTERS, ASI SE UTILIZA
# COMO ENTRADA PARA K-MEANS. POR LO PRONTO UTILIZO SOLO LOS 4 RECOMENDADOS POR EL MÉTODO ANTERIOR.

km = kmeans(dfp_norm1, 4, nstart = 25)


set.seed(123)

print(km)

# Media de cada una de las variables seleccionadas por cluster

km$centers


# Se agrega una variable a la matriz trabajada con el cluster al que pertenece cada supermercado
dfp_norm1_cl4 <- cbind(dfp_norm1, cluster = km$cluster)
head(dfp_norm1_cl4,5)


# Se cuenta la cantidad de sucursales en cada cluster

sum(km$cluster==1) # 18
sum(km$cluster==2) # 32
sum(km$cluster==3) # 38
sum(km$cluster==4) # 71


'En los siguientes gráficos se muestra la representación gráfica de los diferentes clusters, y las observaciones que 
les corresponde a cada uno, considerando las dos variables principales de un análisis de componentes principales. En 
este caso las dos principales variables explican casi el 60% de la variabilidad total de las variables originales.
Se puede apreciar que existe una superposición de cluster. Habría que ver hasta qué punto esta representación es realista
considerando que las variables no están fuertemente correlacionadas, por lo que esta superposción de cluster en dos dimensiones 
del análisis de componentes principales no necesariamente representa una superposición en un espacio de 6 dimensiones.'

fviz_cluster(km, data = dfp_norm1_cl4)
fviz_cluster(km, data = dfp_norm1_cl4, ellipse.type = 'euclid', repel = TRUE, star.plot= TRUE )
fviz_cluster(km, data = dfp_norm1_cl4, ellipse.type = 'norm')



df4 = dfp_norm1_cl4 # se crea otra conjunto de datos para no pisar los que se han ido creando.
                  # en este caso el número 4 corresponde a la cantidad de clusters usado en kmeans
df4
df4 = as.data.frame(df4) # se lo convierte a data frame para poder utilizar la función gather en el siguiente paso
class(df4)
df4[,'cluster'] = factor(df4[,'cluster']) # se convierte la variable cluster en factor, para poder usar la función gather

'se cambia la estructura de la matriz, se convierte a una matriz a lo largo, condensando todas las
variables (excepto cluster) en una sola llamada característica (los nombres de las variables
se encuentran en esta nueva variable), y los valores que tomaban estas variables para cada
medición ahora se encuentran en la nueva variable llamada valor.'

df4_long = gather(df4, caracteristica, valor, 1:6, factor_key = TRUE)
df4_long

# Grafico que muestra la media normalizada de cada variable que le corresponde a cada cluster
# y cómo se distribuyen las diferentes observaciones. 

media_disper_4 = ggplot(df4_long, aes(as.factor(x=caracteristica), y = valor, group =cluster, colour = cluster)) +
  stat_summary(fun = mean, geom = 'pointrange', size = 1) +
  stat_summary(geom = 'line') +
  geom_point(aes(shape=cluster))

media_disper_4 

names(data_out)

tabla_promedio <- aggregate(data_out[c("$ Venta s/IVA","$ Margen AM", "$ Mermas"
                                       , "Costo Laboral (Sin seguridad y Limpieza)", "$Bufet"
                                       , "$ Donacion Mercaderia")]
                           ,by = list(Cat = data_out$), mean, na.rm=TRUE)


tabla_promedio


tabla_min<- aggregate(data_out[c("$ Venta s/IVA","$ Margen AM", "$ Mermas"
                                       , "Costo Laboral (Sin seguridad y Limpieza)", "$Bufet"
                                       , "$ Donacion Mercaderia")]
                            ,by = list(Cat = data_out$cluster), min, na.rm=TRUE)


tabla_min

tabla_max<- aggregate(data_out[c("$ Venta s/IVA","$ Margen AM", "$ Mermas"
                                 , "Costo Laboral (Sin seguridad y Limpieza)", "$Bufet"
                                 , "$ Donacion Mercaderia")]
                      ,by = list(Cat = data_out$cluster), max, na.rm=TRUE)


tabla_max

tablas<-apply(tabla_max, tabla_min, tabla_promedio)
tablas

