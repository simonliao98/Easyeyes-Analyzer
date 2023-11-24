






source('./constant.R')
library(shiny)
library(svglite)
library(shinycssloaders)
# Define UI for application that draws a histogram
shinyUI(
  navbarPage(
    title = textOutput("app_title"),
    tabPanel(
      'Sessions',
      # span(textOutput("experiment"), style="font-size:20px; margin-top:0px"),
      tags$head(# Note the wrapping of the string in HTML()
        tags$style(
          HTML(
            ".navbar{
             margin-bottom: 10px
             }
             .dataTables_filter{
             float: left !important;
             }
             .form-group {
             margin-bottom: 10px;
             }
             .form-group .form-control {
             width: 150px;
             }
             .container-fluid {
             padding-left:5px;
             padding-right:0px;
             }"
          )
        )),
      tags$head(
        tags$script(type = "text/javascript",
                    src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML")
        # tags$script(type = "text/javascript",
        #             src = "https://www.gstatic.com/firebasejs/10.6.0/firebase-app-compat.js"),
        # tags$script(type = "text/javascript",
        #             src = "https://www.gstatic.com/firebasejs/10.6.0/firebase-firestore-compat.js"),
        # tags$script(type = "text/javascript",
        #             src = "https://cdn.jsdelivr.net/npm/chart.js")
        
      ),
      fluidRow(
        column(
          width = 3,
          fileInput(
            "file",
            NULL,
            accept = c(".csv", ".zip"),
            buttonLabel = "Select CSV files or ZIP file",
            multiple = T
          )
        ),
        column(width = 2, downloadButton("report", "Download report")),
        column(width = 2, downloadButton("sessionCsv", "Download csv")),
        column(width = 2, textInput("search", label = NULL))
      ),
      textOutput("instruction"),
      shinycssloaders::withSpinner(DT::dataTableOutput('ex1'), type = 4)
    ),
    tabPanel(
      'Stats',
      fluidRow(
        column(
          width = 2,
          downloadButton("thresholdOne", "Download all participant")
        ),
        column(
          width = 2,
          downloadButton("thresholdTwo", "Download each participant")
        ),
        column(
          width = 2,
          downloadButton("thresholdThree", "Download all threshold")
        )
      ),
      fluidRow(column(12, align = "center", tableOutput('ex3'))),
      fluidRow(column(
        12, align = "center", h3("Summary across participants")
      )),
      fluidRow(column(12, align = "center", tableOutput('ex2'))),
      fluidRow(column(
        12, align = "center", h3("Summary for each participant")
      )),
      fluidRow(
        column(
          width = 12,
          align = "center",
          shinycssloaders::withSpinner(tableOutput('ex4'), type = 4)
        )
      )
    ),
    tabPanel(
      'Plots',
      radioButtons(
        "fileType",
        "Select download file type:",
        c(
          "pdf" = "pdf",
          "eps" = "eps",
          "svg" = "svg"
        ),
        inline = TRUE,
        selected = "pdf"
      ),
      #### font size ####
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("readingVsXheightLog", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("readingVsXheightLinear", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadReadingVsXheightLog", "Download"),
        downloadButton("downloadReadingVsXheightLinear", "Download")
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("reading60cm1.2mmVs1.4mm", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("reading30cm1.2mmVs1.4mm", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadReading60cm1.2mmVs1.4mm", "Download"),
        downloadButton("downloadReading30cm1.2mmVs1.4mm", "Download")
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("reading60cmDiffVsAge", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadReading60cmDiffVsAge", "Download")
      ),
      #### mean - median ####
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("meanPlot", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("medianPlot", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadMeanPlot", "Download"),
        downloadButton("downloadMedianPlot", "Download")
      ),
      #### regression ####
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("regressionPlot", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("regressionAndMeanPlot", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadRegressionPlot", "Download"),
        downloadButton("downloadRegressionAndMeanPlot", "Download")
      ),
      #### regression fonts ####
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("regressionFontPlot", width = "100%"), type = 4),
        shinycssloaders::withSpinner(
          plotOutput("regressionFontPlotWithLabel", width = "100%"),
          type = 4
        )
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadRegressionFontPlot", "Download"),
        downloadButton("downloadRegressionFontPlotWithLabel", "Download")
      ),
      ####fluency ####
      h3("Fluency plots"),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("fluencyHistogram", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadFluencyHistogram", "Download")
      ),
      #### retention ####
      h3("Retention plots"),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("retentionHistogram", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("readingSpeedRetention", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadRetentionHistogram", "Download"),
        downloadButton("downloadReadingSpeedRetention", "Download")
      ),
      #### crowding ####
      h3("Crowding plots"),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("crowdingAvgPlot", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("crowdingScatterPlot", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadCrowdingAvgPlot", "Download"),
        downloadButton("downloadCrowdingScatterPlot", "Download")
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("SloanVsTimesMeanPlot", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("SloanVsTimesSDPlot", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadSloanVsTimesMeanPlot", "Download"),
        downloadButton("downloadSloanVsTimesSDPlot", "Download")
      ),
      h3("Test and Retest plots"),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("readingTestRetest", width = "100%"), type = 4),
        shinycssloaders::withSpinner(plotOutput("crowdingTestRetest", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadReadingTestRetest", "Download"),
        downloadButton("downloadCrowdingTestRetest", "Download")
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        shinycssloaders::withSpinner(plotOutput("rsvpReadingTestRetest", width = "100%"), type = 4)
      ),
      splitLayout(
        cellWidths = c("50%", "50%"),
        downloadButton("downloadRsvpReadingTestRetest", "Download")
      )
    ),
    #### Sound ####
    tabPanel(
      'Sound',
      fixedRow(column(
        width = 4,
        fileInput(
          "fileJSON",
          NULL,
          accept = c(".json"),
          buttonLabel = "Upload json file",
          multiple = F
        )
      )),
      fixedRow(column(
        width = 12, align = "center", h4("Sound Level at 1000 Hz")
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        tableOutput('sound table')
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        h4("Dynamic Range Compression Model")
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        tableOutput('Dynamic Range Compression Model')
      )),
      fixedRow(column(
        width = 12, align = "center", h4("Plots")
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        radioButtons(
          "fileTypeSound",
          "Select download plot type:",
          c(
            "pdf" = "pdf",
            "eps" = "eps",
            "svg" = "svg"
          ),
          inline = TRUE,
          selected = "pdf"
        )
      )),
      #### sound condition ####
      conditionalPanel(
        condition = "output.jsonUploaded",
        fixedRow(
          column(
            width = 12,
            align = "center",
            h4("Inverse Impulse Response")
          ),
          fixedRow(
            column(
              width = 6,
              align = "center",
              withSpinner(plotOutput(
                "IRtmpFour", width = "100%", height = "95%"
              ),
              type = 4)
            ),
            column(
              width = 6,
              align = "center",
              withSpinner(plotOutput(
                "IRtmpFive", width = "100%", height = "95%"
              ),
              type = 4)
            )
          ),
          fixedRow(
            column(
              width = 6,
              align = "center",
              downloadButton("downloadIRtmpFour", "Download")
            ),
            column(
              width = 6,
              align = "center",
              downloadButton("downloadIRtmpFive", "Download")
            )
          ),
          fixedRow(column(
            width = 6,
            align = "center",
            withSpinner(
              plotOutput("componentIIRTime", height = "100%", width = "100%"),
              type = 4
            )
          )),
          fixedRow(column(
            width = 6,
            align = "center",
            downloadButton("downloadComponentIIRTime", "Download")
          )),
          fixedRow(column(
            width = 12, align = "center", h4("Impulse Response")
          )),
          fixedRow(
            column(
              width = 6,
              align = "center",
              withSpinner(
                plotOutput("componentIRTime", height = "100%", width = "100%"),
                type = 4
              )
            ),
            column(
              width = 6,
              align = "center",
              withSpinner(
                plotOutput("componentIRPSD", height = "100%", width = "100%"),
                type = 4
              )
            )
          ),
          fixedRow(
            column(
              width = 6,
              align = "center",
              downloadButton("downloadComponentIRTime", "Download")
            ),
            column(
              width = 6,
              align = "center",
              downloadButton("downloadComponentIRPSD", "Download")
            )
          )
        ),
      ),
      ####  sound all ####
      fixedRow(
        column(
          width = 6,
          align = "center",
          shinycssloaders::withSpinner(imageOutput("sound level plot", height = "100%"), type = 4)
        ),
        column(width = 6, tags$div(
          h6(eq1_text, style = "padding-top:100px;"),
          HTML("Based on Eq. 4 of Giannoulis et al. (2012)."),
          tags$a(href = reference, reference)
        )),
      ),
      fixedRow(column(
        width = 6,
        align = "center",
        downloadButton("downloadSoundLevelPlot", "Download")
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        withSpinner(imageOutput("record freq plot system", height = "100%"), type = 4)
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        downloadButton("downloadRecordFreqPlotSystem", "Download")
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        withSpinner(imageOutput("record freq plot component", height = "100%"), type = 4)
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        downloadButton("downloadRecordFreqPlotComponent", "Download")
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        withSpinner(imageOutput("power variation", height = "100%"), type = 4)
      )),
      fixedRow(column(
        width = 12,
        align = "center",
        downloadButton("downloadPowerVariation", "Download")
      )),
      fluidRow(style = "padding-top:0px;",
               column(
                 width = 12,
                 align = "center",
                 imageOutput("autocorrelation", height = "100%")
               )),
      fixedRow(
        width = 12,
        align = "center",
        actionButton("do", "Plot Autocorrelation")
      ),
      fixedRow(
        width = 12,
        align = "center",
        downloadButton("downloadAutocorrelation", "Download")
      )
    ),
    
    ##### Profiles #####
    
    tabPanel(
      'Profiles',
      actionButton("refreshButton", "Refresh"),
      column(width = 12,
             align = "center",
             div(
               HTML(
                 "<div class='row'>
                 <label style='font-size: 16px; margin-right: 10px'>Transducer: </label><select style='margin-right: 20px;' id='transducer'></select>
                 <label style='font-size: 16px; margin-right: 10px'>OEM: </label><select style='margin-right: 20px;' id='OEM'></select>
                 <label style='font-size: 16px; margin-right: 10px'>Model Name: </label><select style='margin-right: 20px;' id='Model'></select>
                 <label style='font-size: 16px; margin-right: 10px'>Model ID: </label><select style='margin-right: 20px'; id='IDs'></select>
                  <label style='font-size: 16px; margin-right: 10px'>SD Tolerance: </label><input type='number'> </input>
                 </div>
              "
               )
             )),
      # checkbox style selection panel
      # column(width = 12, align = "center", div(HTML("<p style='font-size: 16px'>Select one model</p> <div id='Model'></div>"))),
      fixedRow(
        column(width = 3),
        column(width = 8, div(style = "height: 800px;'", id = "microphonePlots")),
        includeHTML("./www/firestore.html")
      )
    ),
    #     #### Bits ####
    tabPanel(
      'Bits',
      h3("All blocks"),
      textOutput('all participant I'),
      # splitLayout(cellWidths = c("50%", "50%"),
      #             tableOutput('all participant prob')
      # ),
      h3("Each block"),
      tableOutput('each block I')
    )
  )
)