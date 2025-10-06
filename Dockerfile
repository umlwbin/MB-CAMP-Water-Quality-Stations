# Base image with R + Shiny Server
FROM rocker/shiny:4.3.1

# Install required R packages
RUN R -e "install.packages(c('plotly','here','dplyr'), repos='https://cloud.r-project.org/')"

# Copy app.R and the intplots directory into the Shiny server directory
COPY app.R /srv/shiny-server/
COPY intplots /srv/shiny-server/intplots

# Expose Shiny's default port
EXPOSE 3838

# Add a health check: curl the Shiny server homepage every 30s
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3838/ || exit 1

# Start Shiny server
CMD ["/usr/bin/shiny-server"]
