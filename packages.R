# --- Fast & robust CRAN/Bioc + GitHub installs -----------------------------

# usa tutti i core e niente staging (più veloce su VM)
options(Ncpus = max(1L, parallel::detectCores()))
Sys.setenv(R_INSTALL_STAGED = "false")
options(repos = c(CRAN = "https://cloud.r-project.org"))
Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS = "true")

# Mostra dove stiamo installando (utile nei log)
message(sprintf("[packages.R] .libPaths() = %s", paste(.libPaths(), collapse = " | ")))

# ---- helper: NON reinstallare se già presente ----
filter.installed.packages <- function(packageList) {
  if ("-f" %in% commandArgs(trailingOnly = TRUE)) {
    packageList
  } else {
    packageList[!(packageList %in% installed.packages()[, 1])]
  }
}

# rimuove un pacchetto da tutte le librerie note (per forzare reinstall pulita)
remove.installed.packages <- function(pack) {
  for (path in .libPaths()) {
    tryCatch({
      remove.packages(pack, lib = path)
      message(sprintf("removed previously installed package %s from %s", pack, path))
    }, error = function(e) {})
  }
}

# (re-)install di un pacchetto da GitHub, evitando upgrade a cascata
reinstall.package.from.github <- function(package, url) {
  if (package %in% installed.packages()[,1]) remove.installed.packages(package)
  if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools", dependencies = TRUE)
  }
  devtools::install_github(url, upgrade = "never", dependencies = TRUE)
}

# ---------------- Bioconductor deps ----------------
bio_needed <- filter.installed.packages(c("BiRewire", "graph"))
if (length(bio_needed) > 0) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install(bio_needed, ask = FALSE, update = FALSE)
}

# ---------------- CRAN deps ----------------
cran_needed <- filter.installed.packages(c(
  "statnet","ggplot2","tm","optparse","igraph","zoo","xts","lubridate",
  "xtable","reshape","stringr","yaml","plyr","scales",
  "gridExtra","RMySQL","RCurl","mgcv","shiny","dtw","httpuv",
  "corrgram","logging","png","rjson","lsa","RJSONIO","rJava",
  "magick","s2"   # <-- aggiunti qui
))

if (length(cran_needed) > 0) {
  ok <- FALSE
  tryCatch({
    install.packages(cran_needed, dependencies = TRUE, type = "binary")
    ok <- TRUE
  }, error = function(e) message("Binari non disponibili per tutti; provo da sorgente..."))
  if (!ok) {
    install.packages(cran_needed, dependencies = TRUE, type = "source")
  }
}

# ---------------- WordNet (R-Forge, non su CRAN) ----------------
if (!requireNamespace("wordnet", quietly = TRUE)) {
  install.packages("wordnet",
                   repos = "http://r-forge.r-project.org",
                   type  = "source",
                   dependencies = TRUE)
}

# ---------------- GitHub-only / forked pkgs ----------------
reinstall.package.from.github("tm.plugin.mail", "wolfgangmauerer/tm-plugin-mail/pkg")
reinstall.package.from.github("snatm",           "wolfgangmauerer/snatm/pkg")
reinstall.package.from.github("shinyGridster",   "wch/shiny-gridster")
reinstall.package.from.github("shinybootstrap2", "rstudio/shinybootstrap2")
reinstall.package.from.github("Rgraphviz",       "mitchell-joblin/Rgraphviz")

message("[packages.R] installazione pacchetti completata ✅")
