# Trabajo Final - Análisis de Componentes Principales

**Maestría en Métodos Cuantitativos para el Análisis y Gestión de Datos en las Organizaciones**  
**Curso:** Métodos de Análisis Multivariado  
**Docentes:** Silvina Del Duca, Silvia Vietri  
**Grupo N° 3:** Juan Bravo, Antonella Filomeno, Gustavo Funes, Lea Lambrecht

## Introducción

El objetivo principal de este informe es transmitir los resultados de un proceso de identificación de patrones subyacentes y estructuras latentes mediante el análisis de componentes principales (PCA). Se parte de la misma base de datos utilizada para el análisis de conglomerados, y los resultados obtenidos complementarán la segmentación previamente realizada.

## Análisis Descriptivo

Se utilizó una base de datos con 17 variables, excluyendo las variables categóricas. Este trabajo evalúa la interrelación entre las variables y analiza la posibilidad de reducirlas sin perder información. El método de componentes principales transforma las variables originales en un nuevo conjunto de variables no correlacionadas entre sí.

## Supuestos Teóricos

El supuesto teórico más relevante para la aplicación de PCA es la linealidad entre las variables, validada utilizando la matriz de correlación. La matriz de correlación se calculó utilizando el método de correlación de Pearson.

## Método de Componentes Principales (CP)

Para reducir la información de las variables originales, se aplicó el método de CP, conservando los componentes principales (CP) que explican la mayor cantidad de varianza. Se utilizaron dos bibliotecas diferentes en R para verificar los resultados. Las primeras tres componentes explican el 88% de la varianza de las variables originales.

## Interpretación de las Nuevas Variables

- **CP1:** Unidades Vendidas, Margen, Venta C/IVA y Venta S/IVA -> Rendimiento Global
- **CP2:** Donación de Mercadería, Cant. Donaciones -> Responsabilidad Socio-Empresarial
- **CP3:** Costo Promedio, Cantidad de Mermas -> Eficiencia Operativa

## Conclusión

El análisis de componentes principales aplicado a nuestro conjunto de datos ha demostrado ser una herramienta valiosa para reducir la complejidad y destacar patrones fundamentales. Al seleccionar tres componentes principales que explican conjuntamente el 87.8% de la variabilidad original, se ha logrado condensar la información de manera significativa en tres dimensiones: rendimiento global, responsabilidad socio-empresarial y eficiencia operativa.

## Bibliografía

- Aluja, T., Morineau, A. (1999). Aprender de los datos: el análisis de componentes principales, una aproximación desde el datamining. EUB Barcelona.
- Cuadras C. M. (2019). Nuevos Métodos de Análisis Multivariante. CMC Editions Barcelona.
- Johnson, D. E. (2000). Métodos multivariados aplicados al Análisis de Datos. International Thomson Editores. México.
- Joaquín Aldás (2017). Análisis multivariante aplicado con R. Ediciones Paraninfo SA.
