# Multi-stage Dockerfile for CodeFace4Smell
# Replicates Vagrant provisioning with optimized caching

# ============================================================================
# Stage 1: Builder - Compile heavy dependencies
# ============================================================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    NEEDRESTART_MODE=a

# Install build essentials
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential gcc g++ gfortran pkg-config \
    git wget curl ca-certificates gnupg lsb-release \
    libxml2-dev libcurl4-openssl-dev libssl-dev zlib1g-dev \
    libarchive-dev libprotobuf-dev protobuf-compiler \
    libxslt1-dev \
    default-jdk && \
    rm -rf /var/lib/apt/lists/*

# Upgrade cmake to >= 3.28 (required by srcML)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | \
    gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/kitware.list && \
    apt-get update -qq && \
    apt-get install -y cmake && \
    cmake --version

# Build srcML from source
RUN git clone https://github.com/srcML/srcML.git /tmp/srcML && \
    cd /tmp/srcML && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Build abseil-cpp
RUN git clone --depth=1 https://github.com/abseil/abseil-cpp.git /tmp/abseil-cpp && \
    cd /tmp/abseil-cpp && \
    mkdir build && cd build && \
    cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=17 .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Build s2geometry
RUN git clone --depth=1 https://github.com/google/s2geometry.git /tmp/s2geometry && \
    cd /tmp/s2geometry && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=17 -DBUILD_TESTS=OFF && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# ============================================================================
# Stage 2: Runtime - Main application image
# ============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    NEEDRESTART_MODE=a \
    R_LIBS_USER=/opt/Rlibs \
    R_LIBS_SITE=/opt/Rlibs \
    R_INSTALL_STAGED=false \
    WNHOME=/usr/share/wordnet \
    WNSEARCHDIR=/usr/share/wordnet/dict

LABEL maintainer="CodeFace4Smell"
LABEL description="CodeFace analysis environment with Python, R, Node.js"

# Copy compiled libraries from builder
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin/srcml /usr/local/bin/srcml
COPY --from=builder /usr/local/include /usr/local/include
RUN ldconfig

# ============================================================================
# 1. Repository Setup (R + Node.js)
# ============================================================================
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    software-properties-common ca-certificates curl gpg wget gnupg lsb-release && \
    # Add CRAN repository for R
    gpg --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
    gpg --export 51716619E084DAB9 | tee /etc/apt/trusted.gpg.d/cran.gpg && \
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    > /etc/apt/sources.list.d/cran.list && \
    # Add Node.js repository (18 LTS)
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update -qq && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# 2. Install Common Dependencies
# ============================================================================
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    # Core tools
    git subversion nodejs exuberant-ctags sloccount screen \
    graphviz doxygen libgraphviz-dev astyle xsltproc diffstat gdebi-core \
    # Build tools (pkg-config omitted - pkgconf already installed by cmake)
    build-essential gcc gfortran cmake g++ \
    # Libraries
    libxml2 libxml2-dev libcurl4-openssl-dev libcairo2-dev libxt-dev \
    libmysqlclient-dev xorg-dev libx11-dev libgles2-mesa-dev libglu1-mesa-dev \
    libpoppler-dev libpoppler-glib-dev libarchive13 libarchive-dev \
    libmagick++-dev libprotobuf-dev protobuf-compiler \
    libssl-dev zlib1g-dev libxslt1-dev \
    # Python
    python3 python3-dev python3-pip python3-setuptools \
    python3-pkg-resources python3-numpy python3-matplotlib python3-lxml \
    2to3 python3-lib2to3 python3-distutils \
    # R
    r-base r-base-dev \
    libpng-dev libjq-dev libssh2-1-dev \
    libharfbuzz-dev libfribidi-dev libfreetype6-dev libfontconfig1-dev \
    libjpeg-dev libtiff5-dev libgit2-dev libwebp-dev \
    libcairo2-dev libxt-dev libgraphviz-dev \
    # Java (for rJava)
    default-jre default-jdk \
    # WordNet
    wordnet \
    # LaTeX (for reports)
    texlive-latex-base texlive-latex-extra texlive-luatex && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# 3. R Environment Setup
# ============================================================================
RUN mkdir -p /etc/R /opt/Rlibs && \
    chmod 777 /opt/Rlibs && \
    # Configure R to use /opt/Rlibs
    echo '.libPaths(unique(c("/opt/Rlibs", .libPaths())))' > /etc/R/Rprofile.site && \
    echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' >> /etc/R/Rprofile.site && \
    # Parallel builds
    echo "MAKEFLAGS = -j$(nproc)" > /etc/R/Makevars.site && \
    # Configure Java for rJava
    R CMD javareconf

# ============================================================================
# 3.5. Install Shiny Server
# ============================================================================
RUN wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.22.1017-amd64.deb && \
    gdebi -n shiny-server-1.5.22.1017-amd64.deb && \
    rm shiny-server-1.5.22.1017-amd64.deb && \
    # Create log directory (shiny user is created by the package)
    mkdir -p /app/log/shiny-server && \
    chown -R shiny:shiny /app/log/shiny-server

# ============================================================================
# 4. Node.js Environment
# ============================================================================
RUN node -v && npm -v

# ============================================================================
# 5. Python Environment
# ============================================================================
RUN python3 -m pip install --upgrade pip setuptools wheel importlib-metadata && \
    pip3 install --no-cache-dir testresources pymysql notify2 scipy pytest

# ============================================================================
# 6. Application Setup
# ============================================================================
WORKDIR /app

# Copy dependency files first (for better caching)
COPY packages.R packages.minimal.R python_requirements.txt ./
COPY setup.py pyproject.toml ./

# Install R packages (this takes time, so we do it before copying all code)
# Use packages.R which handles the custom R library setup
RUN echo "[Docker] Installing R packages from packages.R..." && \
    Rscript packages.R 2>&1 | tee /tmp/r-install.log || { \
    echo "[Docker] ⚠️  Some R packages failed, checking log..."; \
    cat /tmp/r-install.log; \
    echo "[Docker] Attempting minimal install..."; \
    Rscript packages.minimal.R; \
    }

# Install Shiny-specific packages (separate step to avoid breaking main build)
COPY install-shiny.R ./
RUN echo "[Docker] Installing Shiny dashboard packages..." && \
    Rscript install-shiny.R 2>&1 | tee /tmp/shiny-install.log || { \
    echo "[Docker] ⚠️  Shiny packages failed, dashboard may not work"; \
    cat /tmp/shiny-install.log; \
    }

# Install Python requirements with fallback for platform-specific packages
RUN echo "[Docker] Installing Python requirements..." && \
    # pyinotify is Linux-only, install it separately with error handling
    (pip3 install --no-cache-dir pyinotify 2>/dev/null || echo "pyinotify skipped (not needed on this platform)") && \
    # Install other requirements
    grep -v "pyinotify" python_requirements.txt > /tmp/requirements_filtered.txt && \
    pip3 install --no-cache-dir -r /tmp/requirements_filtered.txt

# Copy application code
COPY codeface ./codeface
COPY bugextractor ./bugextractor
COPY datamodel ./datamodel
COPY id_service ./id_service
COPY integration-scripts ./integration-scripts
COPY conf ./conf
COPY patches ./patches
COPY performance ./performance
COPY experiments ./experiments

# Install Codeface in editable mode
RUN pip3 install --use-pep517 -e . && \
    echo "[Docker] Verifying Codeface installation..." && \
    codeface --help > /dev/null && \
    python3 -c "import codeface; print('[Docker] ✅ Codeface module imported successfully')" && \
    echo "[Docker] ✅ Codeface installed and verified"

# ============================================================================
# 7. cppstats Setup
# ============================================================================
RUN mkdir -p /app/vendor && \
    cd /app/vendor && \
    git clone https://github.com/rosacarota/cppstats.git cppstats-0.8.4 && \
    cd cppstats-0.8.4 && \
    echo '#!/usr/bin/env bash\nset -e\nCPP_DIR="/app/vendor/cppstats-0.8.4"\nPYTHONPATH="$CPP_DIR" exec python3 -m cppstats.cppstats "$@"' > cppstats.sh && \
    chmod +x cppstats.sh && \
    ln -sf /app/vendor/cppstats-0.8.4/cppstats.sh /usr/local/bin/cppstats

# ============================================================================
# 8. Entrypoint
# ============================================================================
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8100

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
