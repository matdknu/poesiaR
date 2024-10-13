library(rvest)
library(jsonlite)
library(readr)
library(openxlsx)

# Definir el path donde se guardarán los archivos

setwd("/Users/matdknu/Dropbox/social-data-science/Proyectos-R/")
path_guardado <- "poesiaR/bbdd"

# Crear el directorio si no existe
if (!dir.exists(path_guardado)) {
  dir.create(path_guardado, recursive = TRUE)
}

# Función para obtener el contenido de una página web usando rvest
obtener_contenido_pagina <- function(url) {
  html <- read_html(url)
  return(html)
}

# Función para extraer los enlaces de los poemas de un autor
extraer_poemas_autor <- function(html) {
  lista_poemas <- html %>% html_nodes('ul#ordenable')  # Lista de poemas
  poemas <- list()

  if (length(lista_poemas) > 0) {
    poemas_links <- lista_poemas %>% html_nodes('a') %>% html_attr('href')
    poemas_titulos <- lista_poemas %>% html_nodes('a') %>% html_text(trim = TRUE)

    for (i in seq_along(poemas_links)) {
      link <- poemas_links[i]
      titulo <- poemas_titulos[i]
      poema_url <- paste0("https://www.poemas-del-alma.com/", link)
      contenido_poema <- extraer_contenido_poema(poema_url)
      poemas[[i]] <- list(titulo = titulo, link = poema_url, contenido = contenido_poema)
    }
  }
  return(poemas)
}

# Función para extraer los poemas de "20 Poemas de Amor" y "Cien Sonetos de Amor"
extraer_poemas_neruda <- function(url) {
  html <- obtener_contenido_pagina(url)
  lista_poemas <- html %>% html_nodes('ul.list-poems')  # Lista de sonetos o poemas
  poemas <- list()

  if (length(lista_poemas) > 0) {
    poemas_links <- lista_poemas %>% html_nodes('a') %>% html_attr('href')
    poemas_titulos <- lista_poemas %>% html_nodes('a') %>% html_text(trim = TRUE)

    for (i in seq_along(poemas_links)) {
      link <- poemas_links[i]
      titulo <- poemas_titulos[i]
      poema_url <- paste0("https://www.poemas-del-alma.com/", link)
      contenido_poema <- extraer_contenido_poema(poema_url)
      poemas[[i]] <- list(titulo = titulo, link = poema_url, contenido = contenido_poema)
    }
  }
  return(poemas)
}

# Función para extraer el contenido de un poema
extraer_contenido_poema <- function(url) {
  html_poema <- obtener_contenido_pagina(url)
  div_poema <- html_poema %>% html_node('div.poem-entry#contentfont')

  if (!is.null(div_poema)) {
    # Dividir el contenido del poema en párrafos, utilizando saltos de línea
    poema_texto <- div_poema %>% html_text(trim = TRUE)
    poema_parrafos <- strsplit(poema_texto, "\n+")[[1]]  # Dividir en párrafos
    return(poema_parrafos)
  }
  return(list())
}

# Guardar los poemas en un archivo Excel con el esquema adecuado
guardar_poemas_excel <- function(poemas, nombre_archivo) {
  wb <- createWorkbook()
  addWorksheet(wb, "Poemas")

  # Crear los nombres de las columnas en el Excel
  writeData(wb, "Poemas", data.frame(autor = character(), titulo = character(), link = character(), poema = character()), startCol = 1, startRow = 1, colNames = TRUE)

  # Escribir los poemas en el archivo Excel sin dejar una fila vacía
  for (i in seq_along(poemas)) {
    poema <- poemas[[i]]
    writeData(wb, "Poemas", x = data.frame(
      autor = poema$autor,
      titulo = poema$titulo,
      link = poema$link,
      poema = paste(poema$contenido, collapse = "\n")  # Unir los párrafos con saltos de línea
    ), startCol = 1, startRow = i + 1, colNames = FALSE)  # Colocar los datos justo después de la cabecera
  }

  saveWorkbook(wb, file = nombre_archivo, overwrite = TRUE)
  cat(paste("\nDatos guardados en", nombre_archivo, "\n"))
}

# Mostrar progreso
mostrar_progreso <- function(actual, total) {
  barra <- paste(rep("|", actual * 40 %/% total), collapse = "")
  espacios <- paste(rep(" ", 40 - nchar(barra)), collapse = "")
  cat(sprintf("\r[%s%s] %d/%d poemas extraídos", barra, espacios, actual, total))
  flush.console()
}

# URLs de los autores a visitar
urls_autores <- list(
  "Armando Uribe" = "https://www.poemas-del-alma.com/armando-uribe-arce.htm",
  "Vicente Huidobro" = "https://www.poemas-del-alma.com/vicente-huidobro.htm",
  "Gabriela Mistral" = "https://www.poemas-del-alma.com/gabriela-mistral.htm",
  "Pablo de Rokha" = "https://www.poemas-del-alma.com/pablo-de-rokha.htm",
  "Mario Benedetti"= "https://www.poemas-del-alma.com/mario-benedetti.htm",
  "Nicanor Parra" = "https://www.poemas-del-alma.com/nicanor-parra.htm",
  "Jorge Luis Borges" = "https://www.poemas-del-alma.com/jorge-luis-borges.htm",
  "Octavio Paz"= "https://www.poemas-del-alma.com/octavio-paz.htm",
  "Julio Cortazar" = "https://www.poemas-del-alma.com/julio-cortazar.htm",
  "Amado Nervo" = "https://www.poemas-del-alma.com/amado-nervo.htm",
  "Ruben Darío" = "https://www.poemas-del-alma.com/ruben-dario.htm",
  "Alejandra Pizarnik" = "https://www.poemas-del-alma.com/alejandra-pizarnik.htm",
  "Ida Vitale" =  "https://www.poemas-del-alma.com/ida-vitale.htm",
  "Roque Dalton" = "https://www.poemas-del-alma.com/roque-dalton-garcia.htm",
  "Salomé Ureña" = "https://www.poemas-del-alma.com/salome-urenia-de-henriquez.htm",
  "Sor Juana"= "https://www.poemas-del-alma.com/sor-juana-ines-de-la-cruz.htm",
  "Rosario Castellanos" = "https://www.poemas-del-alma.com/rosario-castellanos.htm",
  "Gonzalo Rojas" =  "https://www.poemas-del-alma.com/gonzalo-rojas.htm",
  "Pablo Neruda" = "https://www.poemas-del-alma.com/pablo-neruda.htm",
  "Alfonsina Estorni" = "https://www.poemas-del-alma.com/alfonsina-storni.htm",
  "Braulio Arenas" = "https://www.poemas-del-alma.com/braulio-arenas.htm",
  "Federico García Lorca" = "https://www.poemas-del-alma.com/federico-garcia-lorca.htm",
  "Enrique Molina" = "https://www.poemas-del-alma.com/enrique-molina.htm",
  "Francisco de Quevedo"= "https://www.poemas-del-alma.com/francisco-de-quevedo.htm",
  "Gabriel García Márquez" = "https://www.poemas-del-alma.com/gabriel-garcia-marquez.htm",
  "Garcilaso de la Vega" = "https://www.poemas-del-alma.com/garcilaso-de-la-vega.htm",
  "Gustavo Adolfo Becker" = "https://www.poemas-del-alma.com/gustavo-adolfo-becquer.htm",
  "Jorge Tellier" = "https://www.poemas-del-alma.com/jorge-teillier.htm",
  "Juan Egaña" = "https://www.poemas-del-alma.com/juan-egania.htm",
  "José Zorilla" = "https://www.poemas-del-alma.com/jose-zorrilla.htm",
  "Leopoldo Lugones" = "https://www.poemas-del-alma.com/leopoldo-lugones.htm",
  "Lope de Vega" = "https://www.poemas-del-alma.com/lope-de-vega.htm",
  "Manuel Machado" = "https://www.poemas-del-alma.com/manuel-machado-cantares.htm",
  "María Elena Walsh" = "https://www.poemas-del-alma.com/maria-elena-walsh.htm",
  "Marta Zabaleta", "https://www.poemas-del-alma.com/marta-zabaleta.htm",
  "Marta Brunet" = "https://www.poemas-del-alma.com/marta-brunet.htm",
  "Miguel Unamuno" = "https://www.poemas-del-alma.com/miguel-de-unamuno.htm",
  "Oscar Hahn" = "https://www.poemas-del-alma.com/oscar-hahn.htm",
  "Oscar Castro" = "https://www.poemas-del-alma.com/oscar-castro.htm",
  "Rodrigo Lira" = "https://www.poemas-del-alma.com/rodrigo-lira.htm",
  "Silvana Ocampo" = "https://www.poemas-del-alma.com/silvina-ocampo.htm",
  "Tirso de Molina" = "https://www.poemas-del-alma.com/tirso-de-molina.htm",
  "Vicente Rosales" = "https://www.poemas-del-alma.com/vicente-rosales-y-rosales.htm",
  "Wínett de Rokha" = "https://www.poemas-del-alma.com/winett-de-rokha.htm",
  "William Shakespare" = "https://www.poemas-del-alma.com/william-shakespeare.htm"
)

# URLs de Pablo Neruda (20 Poemas de Amor y Cien Sonetos de Amor)
urls_neruda <- list(
  "20 Poemas de Amor" = "https://www.poemas-del-alma.com/20-poemas-de-amor.htm",
  "Cien Sonetos de Amor" = "https://www.poemas-del-alma.com/cien-sonetos-de-amor.htm"
)

# URL de poemas normales de Pablo Neruda
url_poemas_normales_neruda <- "https://www.poemas-del-alma.com/pablo-neruda.htm"

# Procesar autores generales
for (autor in names(urls_autores)) {
  cat(paste("\nExtrayendo poemas de", autor, "...\n"))
  excelfile <- file.path(path_guardado, paste0(tolower(gsub(" ", "_", autor)), "_poemas.xlsx"))

  # Extraer los poemas
  html <- obtener_contenido_pagina(urls_autores[[autor]])
  poemas <- extraer_poemas_autor(html)

  # Guardar los poemas en Excel
  poemas_totales <- list()
  for (i in seq_along(poemas)) {
    poema <- poemas[[i]]
    poema$autor <- autor
    poemas_totales[[i]] <- poema

    # Mostrar progreso
    mostrar_progreso(i, length(poemas))
  }

  guardar_poemas_excel(poemas_totales, excelfile)
}

# Procesar los poemas normales de Pablo Neruda
cat("\nExtrayendo poemas normales de Pablo Neruda...\n")
excelfile_normales <- file.path(path_guardado, "pablo_neruda_poemas_normales.xlsx")

# Extraer los poemas normales de Neruda
html_normales <- obtener_contenido_pagina(url_poemas_normales_neruda)
poemas_normales <- extraer_poemas_autor(html_normales)

# Guardar poemas normales en Excel
poemas_totales_normales <- list()
for (i in seq_along(poemas_normales)) {
  poema <- poemas_normales[[i]]
  poema$autor <- "Pablo Neruda"
  poemas_totales_normales[[i]] <- poema

  # Mostrar progreso
  mostrar_progreso(i, length(poemas_normales))
}
guardar_poemas_excel(poemas_totales_normales, excelfile_normales)

# Procesar Pablo Neruda (20 Poemas de Amor y Cien Sonetos de Amor)
for (categoria in names(urls_neruda)) {
  cat(paste("\nExtrayendo poemas de Pablo Neruda -", categoria, "...\n"))
  excelfile <- file.path(path_guardado, paste0("pablo_neruda_", tolower(gsub(" ", "_", categoria)), ".xlsx"))

  # Extraer los poemas de la categoría específica de Pablo Neruda
  poemas <- extraer_poemas_neruda(urls_neruda[[categoria]])

  # Guardar los poemas en Excel
  poemas_totales <- list()
  for (i in seq_along(poemas)) {
    poema <- poemas[[i]]
    poema$autor <- "Pablo Neruda"
    poemas_totales[[i]] <- poema

    # Mostrar progreso
    mostrar_progreso(i, length(poemas))
  }

  guardar_poemas_excel(poemas_totales, excelfile)
}

# Listar todos los archivos XLSX en el directorio
archivos_xlsx <- list.files(path = path_guardado, pattern = "\\.xlsx$", full.names = TRUE)

# Leer y unir todas las bases de datos en un solo data.frame
base_unica <- archivos_xlsx %>%
  lapply(read_xlsx) %>%  # Leer cada archivo XLSX
  bind_rows()            # Unir todas las bases de datos en una sola

# Mostrar un resumen de la base de datos unificada
print(summary(base_unica))

# Guardar la base de datos unificada en un nuevo archivo XLSX
library(openxlsx)
archivo_unificado <- file.path(path_guardado, "poemas_unificados.xlsx")
write.xlsx(base_unica, archivo_unificado, overwrite = TRUE)
