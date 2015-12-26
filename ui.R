library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("Predict the religion"),
  sidebarPanel(
    h3('Choose a landmass and area, we will try to predict the religion of your fictional country!'),
    selectInput("LandMass", label = h3("Select landmass"), 
                choices = list("S.America" = 1, "Oceania" = 2,
                               "N.America" = 3, "Europe" = 4, 
                               "Asia" = 5 , "Africa"= 6), selected = 1),
    sliderInput("Area", label = h3("Select area (mio of square km)"),
                min = 0.001, max = 4, value = 0.001)
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Prediction", h4('We predict that the religion for this fictional country is '),
               verbatimTextOutput("prediction"), plotOutput("newPlot")), 
      tabPanel("Documentation", 
               h4('This application uses the flags dataset from the UCI machine learning library and attempts to predict the religion of a country from two variables: landmass and area.'),
               h4('The dataset was partitioned in a training and test set and the results for the test set are plotted to the graph. In about 68% of the cases we manage to predict the correct religion from the landmass and area. In the plot you will find correct predictions as circles and wrong predictions as squares.'),
               h4('The user of this application can also make a fictional country by inputting a landmass and area. The results of the prediction of this fictional country are then outputted as text and plotted to the graph (triangle shape)'),
               h4('The algorithm that was used for our prediction was a random forest model.'),
               h4(''),
               h4('The y-axis on the plot represents the different landmasses and the x-axis represents the area in a logscale for thousands of square kms. For example, a 4 on the x-axis represents 4 000 thousand square kms.')
                              )
    )

    )
  )
)