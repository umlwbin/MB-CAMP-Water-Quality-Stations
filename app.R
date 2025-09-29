library(shiny)
library(plotly)
library(here)
library(dplyr)

# Load your data
camp_map_df <- readRDS(here("intplots", "camp_map.rds"))
stations_df <- readRDS(here("intplots", "prov_stations.rds"))

ui <- fluidPage(
  titlePanel("Province of Manitoba and CAMP Water Quality Stations"),
  sidebarLayout(
    sidebarPanel(
      HTML("This interactive map displays the location and dates of sample sites for water quality data collected by the Province of Manitoba, as well as water quality and phytoplank samples collected by the Coordinated Aquatic Monitoring Program (CAMP). Provincial samples were collected between <b>May 24,1973 and August 14,2018 </b>. CAMP samples are the blue dots and represent from the start of the program in <b>2008 until Dec. 31, 2024.</b> <br><br>
           You can toggle off and on layers to view all sample locations for the dataset by clicking on them in the map legend. Select start and end dates from the boxes at the bottom of the map if you want a specific date range. <br><br>
           For the provincial dataset, sample locations are divided into less than or greater than 2 years. <br><br>
           Data is only availabe upon request. Request provincial data by filling out <a href='https://www.gov.mb.ca/sd/pubs/water/lakes-beaches-rivers/data-request-form.pdf' target='_blank'>THIS DATA REQUEST FORM</a>. Request CAMP data <a href='https://www.campmb.ca/request-data' target='_blank'>HERE</a>.<br><br>
           This data is supplemental to Herbert,Claire (2025),A comparison of water quality in the Upper Manitoba Great Lakes. Theis related data and the thesis are located on <a href='https://canwin-datahub.ad.umanitoba.ca/data/project/satelllite-mbgl' target='_blank'>CanWIN</a> <br><br>
           Cite this interactive map as 'Herbert, Claire, 2025, Interactive map of Province of Manitoba and CAMP locations, Canadian Watershed Information Network (CanWIN), Version 1.0"

    )
  ),
    mainPanel(
      plotlyOutput("combined_map", height = "700px"),

      # Row with two date inputs at bottom
      fluidRow(
        column(6,
               dateInput(
                 inputId = "start_date",
                 label = "Select Start Date",
                 value = min(stations_df$Start_Date, na.rm = TRUE),
                 format = "yyyy-mm-dd"
               )
        ),
        column(6,
               dateInput(
                 inputId = "end_date",
                 label = "Select End Date",
                 value = max(stations_df$End_Date, na.rm = TRUE),
                 format = "yyyy-mm-dd"
               )
        )
      )
    )
  )
)
server <- function(input, output, session) {
  output$combined_map <- renderPlotly({
    # Filter by overlapping date range (assuming Date columns are Date-class)
    stations_filtered <- stations_df %>%
      filter(!(End_Date < input$start_date | Start_Date > input$end_date))

    stations_ge2 <- stations_filtered %>% filter(Data_Years > 2)
    stations_lt2 <- stations_filtered %>% filter(Data_Years <= 2)

    plot_ly(
      data = camp_map_df,
      type = 'scattermapbox',
      mode = 'markers+text',
      lat = ~Latitude,
      lon = ~Longitude,
      text = ~`Published Site No.`,
      textposition = "top center",
      marker = list(size = 11, color = 'blue', symbol = 'circle', opacity = 1),
      hoverinfo = 'text',
      hovertext = ~hover_text,
      name = "CAMP Sites"
    ) %>%
      add_trace(
        data = stations_ge2,
        type = 'scattermapbox',
        mode = 'markers+text',
        lat = ~Decimal_Latitude,
        lon = ~Decimal_Longitude,
        text = ~STATION_NO,
        textposition = "top center",
        marker = list(size = 6, color = 'green', symbol = 'circle', opacity = 1),
        hoverinfo = 'text',
        hovertext = ~hover_text,
        name = "Provincial Station with > 2 years of data"
      ) %>%
      add_trace(
        data = stations_lt2,
        type = 'scattermapbox',
        mode = 'markers+text',
        lat = ~Decimal_Latitude,
        lon = ~Decimal_Longitude,
        text = ~STATION_NO,
        textposition = "top center",
        marker = list(size = 6, color = 'red', symbol = 'circle', opacity = 1),
        hoverinfo = 'text',
        hovertext = ~hover_text,
        name = "Provincial Station with ≤ 2 years of data"
      ) %>%
      layout(
        mapbox = list(
          style = "open-street-map",
          zoom = 5,
          center = list(
            lat = mean(c(camp_map_df$Latitude, stations_filtered$Decimal_Latitude), na.rm = TRUE),
            lon = mean(c(camp_map_df$Longitude, stations_filtered$Decimal_Longitude), na.rm = TRUE)
          )
        ),
        margin = list(l = 0, r = 0, t = 0, b = 0),
        legend = list(x = 0.1, y = 0.9)
      )
  })
}

# Run app
shinyApp(ui, server)