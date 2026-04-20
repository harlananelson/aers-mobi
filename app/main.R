# aers.mobi — Historical AERS (2004-2012) signal detection
#
# Focus: pre-FAERS era adverse event reporting. Classic safety case studies
# including the Vioxx / myocardial infarction era, Avandia, Baycol, etc.
# Modern FAERS data (2012+) lives at faers.mobi.

box::use(
  shiny[
    moduleServer, NS, tags, div, h4, p, hr, fluidRow, column,
    fileInput, reactive, req, fluidPage, navbarPage, tabPanel
  ],
  bslib[bs_theme],
)

box::use(
  app/view/signal_table,
  app/view/signal_timeline,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  navbarPage(
    title = "aers.mobi — Historical AERS (2004-2012)",
    theme = bs_theme(bootswatch = "cosmo"),

    # Primary: precomputed signals caterpillar plot
    tabPanel("Signals over time",
      fluidPage(
        div(class = "container-fluid", style = "padding-top: 20px;",
          signal_timeline$ui(ns("timeline"))
        )
      )
    ),

    # Legacy: bring-your-own CSV
    tabPanel("Upload CSV",
      fluidPage(
        div(class = "container-fluid", style = "padding-top: 20px;",
          fluidRow(
            column(12,
              h4("Bayesian Gamma-Poisson Signal Detection"),
              p("Upload your own AE report CSV (columns: product, event) to run ",
                "disproportionality analysis in the browser. For precomputed ",
                "historical AERS signals, see the ", tags$em("Signals over time"), " tab."),
              hr()
            )
          ),
          fluidRow(
            column(6,
              fileInput(ns("data_file"), "Upload data (CSV):", accept = ".csv")
            ),
            column(6,
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
          tags$p("Signal detection over the legacy AERS database (2004-2012), ",
                 "the predecessor to FAERS. Captures the classic case studies ",
                 "of the era: Vioxx / myocardial infarction (withdrawn 2004), ",
                 "Avandia, Baycol, and many others."),
          tags$p("Companion to ", tags$a(href = "https://faers.mobi", "faers.mobi"),
                 " which covers the current FAERS era (2018 onward)."),
          tags$h3("Data source"),
          tags$p("AERS quarterly ASCII dumps from FDA, processed through the same ",
                 tags$a(href = "https://github.com/harlananelson/faers-pipeline", "R/targets pipeline"),
                 " as faers.mobi with era-aware schema handling (ISR/CASE -> primaryid/caseid)."),
          tags$h3("Statistical methods"),
          tags$ul(
            tags$li("GPS/EBGM with 2-component Gamma mixture prior (DuMouchel 1999)"),
            tags$li("PRR + Yates chi-squared (Evans 2001)"),
            tags$li("ROR with log-normal CI (van Puijenbroek 2002)"),
            tags$li("BCPNN/IC with 95% credibility bound (Bate 1998)")
          ),
          tags$h3("Disclaimer"),
          tags$p("Disproportionate reporting is a statistical pattern, not evidence ",
                 "of causation. Signals are hypotheses requiring further investigation.")
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    signal_timeline$server("timeline")

    uploaded_data <- reactive({
      req(input$data_file)
      utils::read.csv(input$data_file$datapath, stringsAsFactors = FALSE)
    })

    signal_table$server("signals", data = uploaded_data)
  })
}
