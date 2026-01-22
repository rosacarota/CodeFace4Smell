library(shiny)
ui <- fluidPage(
  titlePanel("🚀 Shiny Server Test - It Works!"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Number of points:", 1, 1000, 500)
    ),
    mainPanel(
      plotOutput("distPlot")
    )
  )
)
server <- function(input, output) {
  output$distPlot <- renderPlot({
    hist(rnorm(input$obs), col = "#66c2a5", border = "white", main = "Random histogram")
  })
}
shinyApp(ui = ui, server = server)
