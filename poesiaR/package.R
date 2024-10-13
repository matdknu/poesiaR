install.packages("devtools")
install.packages("usethis")
install.packages("roxygen2")

library(devtools)
library(usethis)
library(roxygen2)
library(readxl)


getwd()
create_package("package/poesiaR")


usethis::use_data_raw(name = "package/bbdd", open = FALSE)


poesia_df <- read_excel("data-raw/poemas_unificados.xlsx")


# Guardar la base de datos en el formato .rda dentro del paquete
usethis::use_data(poesia_df, overwrite = TRUE)


#' Base de datos de poesía
#'
#' Una base de datos que contiene información sobre poemas.
#'
#' @format Un data frame con X filas y Y columnas:
#' \describe{
#'   \item{autor}{Nombre del autor del poema}
#'   \item{titulo}{Título del poema}
#'   \item{texto}{Contenido del poema}
#'   \item{año}{Año de publicación}
#' }
#' @source {Indica la fuente de los datos, si es relevante}
#' @examples
#' data(poesia_df)
#' head(poesia_df)
"poesia_df"


setwd("package/")
devtools::document()  # Genera la documentación si hay alguna
devtools::build()     # Construye el paquete
devtools::install()   # Instala el paquete localmente


library(poesiaR)
data(poesia_df)
head(poesia_df)


