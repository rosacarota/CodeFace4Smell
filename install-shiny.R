#!/usr/bin/env Rscript
# Post-build script to install Shiny-specific packages
# This runs after the main packages.R to ensure Shiny dashboard works

message("[install-shiny.R] Installing Shiny dashboard packages...")

options(Ncpus = max(1L, parallel::detectCores()))
Sys.setenv(R_INSTALL_STAGED = "false")
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE)) {
    message("[install-shiny.R] Installing devtools...")
    install.packages("devtools", dependencies = TRUE)
}

# Install shinyGridster from GitHub
if (!requireNamespace("shinyGridster", quietly = TRUE)) {
    message("[install-shiny.R] Installing shinyGridster from GitHub...")
    tryCatch(
        {
            devtools::install_github("wch/shiny-gridster", upgrade = "never", dependencies = TRUE)
            message("[install-shiny.R] ✓ shinyGridster installed successfully")
        },
        error = function(e) {
            message("[install-shiny.R] ✗ Failed to install shinyGridster: ", e$message)
        }
    )
} else {
    message("[install-shiny.R] shinyGridster already installed")
}

# Install shinybootstrap2 from GitHub
if (!requireNamespace("shinybootstrap2", quietly = TRUE)) {
    message("[install-shiny.R] Installing shinybootstrap2 from GitHub...")
    tryCatch(
        {
            devtools::install_github("rstudio/shinybootstrap2", upgrade = "never", dependencies = TRUE)
            message("[install-shiny.R] ✓ shinybootstrap2 installed successfully")
        },
        error = function(e) {
            message("[install-shiny.R] ✗ Failed to install shinybootstrap2: ", e$message)
        }
    )
} else {
    message("[install-shiny.R] shinybootstrap2 already installed")
}

message("[install-shiny.R] Done!")
