# Codeface Docker Guide

This guide covers everything you need to know about running Codeface using Docker.

## 1. Prerequisites (Codeface4Smell)

- **Docker Desktop**: [Install here](https://www.docker.com/products/docker-desktop/)
- **Git**: [Install here](https://git-scm.com/downloads)
- **RAM**: At least 8-16 GB allocated to Docker (Codeface is memory intensive)

## 2. Quick Start

### Start the System

1. Open a terminal in the project directory.
2. Build and start the containers:
   ```bash
   docker-compose up -d --build
   ```
   *(The first build may take 15-30 minutes as it compiles required libraries)*

3. Check if services are running:
   ```bash
   docker-compose ps
   ```

4. Access the Shiny Dashboard:
   - Open **http://localhost:8081** in your browser.

### Run an Analysis (Example: PHP)

1. Create `repos/` directory and clone the repository on your machine:
   ```bash
   mkdir -p repos
   cd repos
   git clone https://github.com/php/php-src.git
   cd ..
   ```
   
2. Run the analysis:
   ```bash
   docker-compose exec codeface-app codeface run -c codeface.conf -p conf/php.conf res/php repos
   ```

3. View results in the Shiny Dashboard at **http://localhost:8081**

> **Note**: The `repos/` directory is mounted from your host machine and excluded from git.
> Repositories cloned here persist even when containers are recreated.

## 3. Architecture

The setup consists of 3 connected services:

- **`codeface-db`**: MariaDB 10.11 database (stores analysis data)
- **`codeface-app`**: Main application container (runs Python/R analysis tools)
- **`codeface-shiny`**: R Shiny Server (hosts the interactive dashboard)

### Data Persistence

- **Docker Volumes**: `mysql-data` (database), `r-libs` (R packages)
- **Local Mounts**: `./repos` (git repositories), `./res` (results), `./log` (logs)

### Installed Packages

**System Tools:**
- **Version Control**: Git, Subversion
- **Build Tools**: CMake, gcc, g++, gfortran
- **Code Analysis**: srcML, sloccount, diffstat, exuberant-ctags
- **Visualization**: Graphviz, Doxygen
- **Documentation**: LaTeX (texlive-latex-base, texlive-latex-extra, texlive-luatex)

**R Packages (Core):**
- **Shiny**: shiny, shinyGridster, shinybootstrap2
- **Database**: DBI, RMySQL
- **Data**: data.table, zoo, xts, lubridate
- **Visualization**: ggplot2, gridExtra, scales, Rgraphviz
- **Text**: tm, wordcloud, SnowballC
- **Network**: igraph, sna
- **Utilities**: stringr, plyr, reshape2, devtools

**Python Packages:**
- **Database**: pymysql
- **Scientific**: scipy, numpy, matplotlib
- **Parsing**: lxml
- **Testing**: pytest, testresources

**Node.js:**
- ID service for entity resolution (runs on port 8100)

## 4. System Requirements

**Minimum:**
- 8 GB RAM allocated to Docker
- 20 GB free disk space
- Docker Desktop 4.0+
- Stable internet connection (for initial build)

**Recommended:**
- 16 GB RAM allocated to Docker
- 50 GB free disk space (for large repositories)
- SSD for better I/O performance

## 5. Troubleshooting

### Build Issues
- **Timeouts**: If dependency installation fails, check your internet connection and try building again.
- **Memory**: If the build crashes, increase Docker's RAM limit to 8GB or more.

### Runtime Issues
- **Dashboard not loading**: Check logs with:
  ```bash
  docker-compose logs codeface-shiny
  ```
- **"Package not found"**: If an R package is missing, restart the container to let the fix scripts run:
  ```bash
  docker-compose restart codeface-shiny
  ```

### Full Reset (Clean Slate)

To stop everything and delete all data (database and results):

```bash
# Stop containers and remove volumes
docker-compose down -v
```

## 6. Development

- **Configuration**: Edit `codeface.conf` for global settings or `conf/*.conf` for project settings.
- **Logs**: Check `./log/` directory for detailed application logs.
- **R Package Development**: Packages are cached in `r-libs` volume for faster rebuilds.
- **Database Access**: Connect to `localhost:3306` with credentials from `codeface.conf`.
