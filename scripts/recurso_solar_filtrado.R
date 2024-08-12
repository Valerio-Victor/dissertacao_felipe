# PACOTES: ----------------------------------------------------------------
library(magrittr, include.only = '%>%')
library(ggplot2)
library(nasapower)


# IMPORTAÇÃO: -------------------------------------------------------------
url_aneel <- 'https://dadosabertos.aneel.gov.br/'

ckanr::ckanr_setup(url_aneel)

url_dados <- ckanr::resource_show(id = 'b1bd71e7-d0ad-4214-9053-cbd58e9564a7')

url_final <- (url_dados$url)

dados <- readr::read_delim(file = url_final,
                           delim = ';',
                           escape_double = FALSE,
                           col_types = readr::cols(
                             DatGeracaoConjuntoDados =
                               readr::col_date(format = '%Y-%m-%d'),
                             AnmPeriodoReferencia =
                               readr::col_date(format = '%m/%Y'),
                             DthAtualizaCadastralEmpreend =
                               readr::col_date(format = '%Y-%m-%d'),
                             NumCoordNEmpreendimento =
                               readr::col_character(),
                             NumCoordEEmpreendimento =
                               readr::col_character()),
                           locale = readr::locale(encoding = 'ISO-8859-1'),
                           trim_ws = TRUE)


# ARRUMAÇÃO: --------------------------------------------------------------
filtro_municipio_inst <- dados %>%
  janitor::clean_names() %>%
  dplyr::filter(sig_uf == 'MG') %>%
  dplyr::select(nom_municipio,dsc_modalidade_habilitado) %>%
  dplyr::filter(dsc_modalidade_habilitado == 'Caracterizada como Geracao compartilhada') %>%
  table() %>%
  as.data.frame() %>%
  dplyr::arrange(desc(Freq))


# IMPORTAÇÃO_LATITUDE_LONGITUDE: ------------------------------------------
lon_lat <- geobr::read_municipal_seat()

# IMPORTAÇÃO DE RECURSO SOLAR: --------------------------------------------
recurso_solar <- get_power(
  community = 're',
  lonlat = c(-43.86542, -16.72271),
  dates = c('2023-01-01', '2023-12-31'),
  temporal_api = 'hourly',
  pars = c('ALLSKY_SFC_SW_DWN')
) %>%
  as.data.frame() %>%
  janitor::clean_names() %>%
  dplyr::mutate(recurso_solar = allsky_sfc_sw_dwn/1000)


colnames(recurso_solar)

