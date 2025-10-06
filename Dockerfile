FROM rocker/shiny:4.3.1

# Install curl and R packages
RUN apt-get update && apt-get install -y curl \
    && R -e "install.packages(c('plotly','here','dplyr'), repos='https://cloud.r-project.org/')"

COPY app.R /srv/shiny-server/
COPY intplots /srv/shiny-server/intplots

EXPOSE 3838

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3838/ || exit 1

CMD ["/usr/bin/shiny-server"]