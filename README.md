# CodeFace4Smell

**CodeFace4Smell** is a fork of [CodeFace](https://github.com/siemens/codeface) extended for code smell analysis and software evolution research.

##  Quick Start (Docker)

**Prerequisites:**
- Docker Desktop ([Install](https://www.docker.com/products/docker-desktop/))
- Git
- 8-16 GB RAM allocated to Docker

**Setup:**
```bash
# 1. Clone the repository
git clone https://github.com/rosacarota/CodeFace4Smell.git
cd CodeFace4Smell

# 2. Build and start containers
docker-compose up -d --build

# 3. Access the dashboard
# Open http://localhost:8081 in your browser
```

**Run an analysis:**
```bash
# 1. Clone a repository to analyze
mkdir -p repos
cd repos
git clone https://github.com/php/php-src.git
cd ..

# 2. Run analysis
docker-compose exec codeface-app codeface run -c codeface.conf -p conf/php.conf res/php repos

# 3. View results at http://localhost:8081
```
 **For detailed instructions, see [DOCKER_GUIDE.md](DOCKER_GUIDE.md)**

## What's Included

### Docker Services
- **codeface-db**: MariaDB 10.11 database for analysis data
- **codeface-app**: Main analysis engine (Python + R + Git tools)
- **codeface-shiny**: R Shiny Server for interactive dashboard

### Key Features
- **Multi-language analysis**: Python, R, C++, JavaScript
- **Git repository analysis**: Commit history, contributors, collaboration patterns
- **Code metrics**: Complexity, SLOC, code smells
- **Interactive dashboard**: Real-time visualization with R Shiny
- **Mailing list analysis**: Communication patterns (optional)
- **Time series analysis**: Evolution tracking across releases

### Installed Tools & Packages

**System Tools:**
- Git, Subversion, CMake, srcML
- diffstat, sloccount, exuberant-ctags
- Graphviz, Doxygen, LaTeX (for reports)

**R Packages:**
- Core: shiny, DBI, RMySQL, ggplot2, igraph
- Dashboard: shinyGridster, shinybootstrap2
- Analysis: tm, wordcloud, zoo, xts, lubridate
- Visualization: Rgraphviz, gridExtra, scales

**Python Packages:**
- Database: pymysql
- Analysis: scipy, numpy, matplotlib
- Utilities: lxml, testresources

**Node.js:**
- ID service for entity resolution

## Project Structure

```
CodeFace4Smell/
├── codeface/           # Main application code
│   ├── R/             # R analysis scripts
│   │   └── shiny/     # Dashboard apps
│   └── *.py           # Python analysis modules
├── conf/              # Project configurations
├── docker/            # Docker configuration files
├── repos/             # Git repositories to analyze (not in git)
├── res/               # Analysis results
├── log/               # Application logs
├── Dockerfile         # Docker image definition
└── docker-compose.yml # Multi-container setup
```

## Configuration

### Global Settings (`codeface.conf`)
- Database connection
- ID service port
- Analysis tool toggles (sloccount, understand)

### Project Settings (`conf/*.conf`)
- Repository path
- Release tags/revisions
- Mailing list sources (optional)
- Analysis parameters

## Dashboard Features

Access the Shiny dashboard at `http://localhost:8081` to view:

- **Project Overview**: Health indicators for Collaboration, Construction, Communication, Complexity
- **Commit Analysis**: Developer activity, timezone distribution
- **Release Analysis**: Time series metrics across versions
- **Collaboration Networks**: Developer interaction graphs
- **Code Metrics**: Complexity trends, SLOC evolution

## Troubleshooting

**Dashboard not loading:**
```bash
docker-compose logs codeface-shiny
docker-compose restart codeface-shiny
```

**Analysis fails:**
```bash
docker-compose logs codeface-app
# Check that repository exists in repos/
```

**Database issues:**
```bash
docker-compose logs codeface-db
# Reset database:
docker-compose down -v
docker-compose up -d
```

## Documentation

- **[DOCKER_GUIDE.md](DOCKER_GUIDE.md)** - Comprehensive Docker setup guide
- **[repos/README.md](repos/README.md)** - Repository management
- **Python API**: Run `python setup.py build_sphinx` (output in `build/sphinx/html`)

##  Research & Citations

CodeFace is designed for empirical software engineering research. If you use this tool in your research, please cite the original CodeFace project.

## License

See LICENSE file for details.

## Contributing

This is a research fork. For the original project, see [siemens/codeface](https://github.com/siemens/codeface).

---

## Legacy Setup (Not Recommended)

<details>
<summary>Vagrant Setup (Deprecated)</summary>

The original Vagrant-based setup is no longer maintained. Use Docker instead.

If you must use Vagrant:
```bash
vagrant up
vagrant ssh
```

</details>
