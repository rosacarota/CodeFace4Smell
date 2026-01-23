#!/usr/bin/env Rscript
# Install missing Shiny packages

message("[install-shiny-packages.R] Installing shinyGridster...")

# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools", repos = "https://cloud.r-project.org")
}

# Install shinyGridster from GitHub
devtools::install_github("wch/shiny-gridster", upgrade = "never", dependencies = TRUE)

# Verify installation
if (requireNamespace("shinyGridster", quietly = TRUE)) {
    message("[install-shiny-packages.R] ✓ shinyGridster installed successfully")
} else {
    stop("[install-shiny-packages.R] ✗ shinyGridster installation failed")
}

message("[install-shiny-packages.R] Done!")
