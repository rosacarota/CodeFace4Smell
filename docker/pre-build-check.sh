#!/bin/bash
# Pre-build verification script
# Checks for common issues before Docker build

set -e

echo "🔍 Pre-build verification for CodeFace4Smell Docker migration"
echo "=============================================================="

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi
echo "✅ Docker found: $(docker --version)"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed or not in PATH"
    exit 1
fi
echo "✅ Docker Compose found: $(docker-compose --version)"

# Check required files exist
REQUIRED_FILES=(
    "Dockerfile"
    "docker-compose.yml"
    "packages.R"
    "setup.py"
    "python_requirements.txt"
    "docker/entrypoint.sh"
    "docker/init-db.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Required file missing: $file"
        exit 1
    fi
done
echo "✅ All required files present"

# Check critical Python 3 migration points
echo ""
echo "🔍 Checking Python 3 migration..."

# Check setup.py uses Python 3 compatible packages
if grep -q "python_ctags3" setup.py && grep -q "pymysql" setup.py; then
    echo "✅ setup.py uses Python 3 packages (python_ctags3, pymysql)"
else
    echo "⚠️  setup.py might have Python 2 dependencies"
fi

# Check for Python 2 remnants
if grep -rq "python2" integration-scripts/ 2>/dev/null; then
    echo "⚠️  Found 'python2' references in integration-scripts (might be commented out)"
else
    echo "✅ No Python 2 references in integration-scripts"
fi

# Check cppstats fork
echo ""
echo "🔍 Checking cppstats fork..."
if grep -q "rosacarota/cppstats" Dockerfile; then
    echo "✅ Dockerfile uses rosacarota/cppstats fork"
else
    echo "❌ Dockerfile doesn't use the correct cppstats fork!"
    exit 1
fi

# Check R packages setup
echo ""
echo "🔍 Checking R packages configuration..."
if [ -f "packages.R" ]; then
    if grep -q "filter.installed.packages" packages.R; then
        echo "✅ packages.R has smart package installation logic"
    fi
    if grep -q "BiocManager" packages.R; then
        echo "✅ packages.R includes Bioconductor setup"
    fi
    if grep -q "devtools::install_github" packages.R; then
        echo "✅ packages.R installs GitHub packages"
    fi
fi

# Check datamodel schema exists
echo ""
echo "🔍 Checking database schema..."
if [ -f "datamodel/codeface_schema.sql" ]; then
    echo "✅ Database schema found"
else
    echo "⚠️  Database schema not found at datamodel/codeface_schema.sql"
fi

# Disk space check
echo ""
echo "🔍 Checking disk space..."
AVAILABLE_GB=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_GB" -lt 20 ]; then
    echo "⚠️  Low disk space: ${AVAILABLE_GB}GB available (recommend 20GB+)"
else
    echo "✅ Sufficient disk space: ${AVAILABLE_GB}GB available"
fi

echo ""
echo "=============================================================="
echo "✅ Pre-build verification completed!"
echo ""
echo "You can now run:"
echo "  docker-compose build"
echo ""
echo "⏱️  Expected build time: 15-25 minutes (first time)"
echo "📝 Build logs will show detailed progress"
