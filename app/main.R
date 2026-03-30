# aers.mobi — Drug & Device Adverse Event Signal Detection (FAERS + MAUDE)

box::use(
  shiny[bootstrapPage, moduleServer, NS, tags, div, fluidPage, navbarPage,
        tabPanel, fileInput, reactive, req, observeEvent, h4, p, hr,
        fluidRow, column, selectInput],
)

box::use(
  app/view/signal_table,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  navbarPage(
    title = "aers.mobi — Drug & Device Safety Signal Detection",
    theme = bslib::bs_theme(bootswatch = "cosmo"),
    tabPanel("Signal Detection",
      fluidPage(
        div(class = "container-fluid", style = "padding-top: 20px;",
          fluidRow(
            column(12,
              h4("Bayesian Gamma-Poisson Signal Detection for Drugs & Devices"),
              p("Upload FAERS or MAUDE data (CSV with product, adverse event columns) to detect ",
                "disproportionate reporting signals."),
              hr()
            )
          ),
          fluidRow(
            column(4,
              fileInput(ns("data_file"), "Upload data (CSV):", accept = ".csv")
            ),
            column(4,
              selectInput(ns("data_source"), "Data source:",
                          choices = c("FAERS (Drugs)" = "faers",
                                      "MAUDE (Devices)" = "maude"))
            ),
            column(4,
              p(tags$strong("Expected columns:"), " product, event"),
              p("Each row = one adverse event report.")
            )
          ),
          signal_table$ui(ns("signals"))
        )
      )
    ),
    tabPanel("About",
      fluidPage(
        div(style = "max-width: 800px; margin: 40px auto;",
          tags$h2("About aers.mobi"),
          tags$p("Bayesian disproportionality analysis for drug and medical device ",
                 "adverse event reporting using FDA data sources."),
          tags$h3("Data Sources"),
          tags$ul(
            tags$li(tags$strong("FAERS"), " — FDA Adverse Event Reporting System (drugs & biologics)"),
            tags$li(tags$strong("MAUDE"), " — Manufacturer and User Facility Device Experience (medical devices)")
          ),
          tags$h3("Statistical Method"),
          tags$ul(
            tags$li("Prior: 2-component Gamma mixture fitted via EM algorithm"),
            tags$li("Posterior: full Gamma mixture (not EBGM approximation)"),
            tags$li("Signal: EB05 (5th percentile of posterior) > threshold"),
            tags$li("Reference: DuMouchel (1999), American Statistician 53(3)")
          )
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    uploaded_data <- reactive({
      req(input$data_file)
      utils::read.csv(input$data_file$datapath, stringsAsFactors = FALSE)
    })

    signal_table$server("signals", data = uploaded_data)
  })
}
