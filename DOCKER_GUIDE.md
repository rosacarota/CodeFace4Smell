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

1. Enter the main application container:
   ```bash
   docker-compose exec codeface-app bash
   ```

2. Inside the container, clone the repository to analyze:
   ```bash
   cd /app/repos
   git clone https://github.com/php/php-src.git
   ```

3. Run the analysis command:
   ```bash
   cd /app
   codeface run -c codeface.conf -p conf/php.conf res/php repos
   ```

4. View results in the Shiny Dashboard (http://localhost:8081).

## 3. Architecture

The setup consists of 3 connected services:

- **`codeface-db`**: MariaDB database (stores analysis data).
- **`codeface-app`**: Main application container (runs the Python/R analysis tools).
- **`codeface-shiny`**: R Shiny server (hosts the visualization dashboard).

Data is persisted in Docker volumes (`mysql-data`, `r-libs`) and local folders (`res`, `log`).

## 4. Troubleshooting

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

## 5. Development

- **Configuration**: Edit `codeface.conf` for global settings or `conf/*.conf` for project settings.
- **Logs**: Check `./log/` directory for detailed application logs.
