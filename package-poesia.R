# Instala las herramientas necesarias si no están ya instaladas
install.packages("devtools")
install.packages("usethis")
install.packages("roxygen2")

# Cargar las librerías
library(devtools)
library(usethis)
library(roxygen2)

# Configura el directorio de trabajo
setwd("/Users/matdknu/Dropbox/social-data-science/Proyectos-R/poesiaR")

# Crea el paquete
create_package("poesiaR")
1





# Crea la carpeta data-raw si no existe
usethis::use_data_raw(name = "poemas_unificados", open = FALSE)

# Carga el archivo Excel
library(readxl)
poesia_df <- read_excel("data-raw/poemas_unificados.xlsx")

usethis::use_description()
2
usethis::use_namespace()


# Guarda la base de datos en formato .rda en la carpeta data/
usethis::use_data(poesia_df, overwrite = TRUE)

devtools::document()


devtools::build()
devtools::install()

library(poesiaR)

# Cargar los datos
data(poesia_df)

# Verificar las primeras filas
head(poesia_df)

usethis::use_mit_license()


usethis::use_git()
2

devtools::check()


