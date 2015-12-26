library(shiny)
library('dplyr')
library('caret')
library('randomForest')

#get data and assign column names
#datasource: "https://archive.ics.uci.edu/ml/machine-learning-databases/flags/flag.data"
fl <- read.table("./data/flags.data", sep=",", header=FALSE)
names(fl) <- c("name","landmass","zone","area","population","language","religion","bars","stripes","colours","red","green","blue","gold","white","black","orange","mainhue","circles","crosses","saltires","quarters","sunstars","crescent","triangle","icon","animate","text","topleft","botright") 

#predict religion from religion, landmass, area
flags <- fl[,c("religion","landmass","area")]

#convert to understandable categories
flags$religion[flags$religion==0] <- "Catholic"
flags$religion[flags$religion==1] <- "Christian"
flags$religion[flags$religion==2] <- "Muslim"
flags$religion[flags$religion==3] <- "Buddhist"
flags$religion[flags$religion==4] <- "Hindu"
flags$religion[flags$religion==5] <- "Ethnic"
flags$religion[flags$religion==6] <- "Marxist"
flags$religion[flags$religion==7] <- "Others"
flags$landmass[flags$landmass==1] <- "N.America"
flags$landmass[flags$landmass==2] <- "S.America"
flags$landmass[flags$landmass==3] <- "Europe"
flags$landmass[flags$landmass==4] <- "Africa"
flags$landmass[flags$landmass==5] <- "Asia"
flags$landmass[flags$landmass==6] <- "Oceania"

#create factor variables
flags$religion<- factor(flags$religion)
flags$landmass<- factor(flags$landmass)

#set seed, make data partitions
set.seed(6542)
inTrain = createDataPartition(flags$religion, p = 3/4)[[1]]
training = flags[ inTrain,]
testing = flags[-inTrain,]

#train randomforest, prediction not needed here
rfMod <- randomForest(religion ~., data=training, importance=TRUE)
#rfPred <- predict(rfMod, newdata = testing)


predictReligion <- function(landMassInput, areaInput){
  #this function will predict the religion of the user input
  
  #convert user input to correct value
if (landMassInput == 1) {landMassInputS = "S.America"} else
  if (landMassInput == 2) {landMassInputS = "Oceania"} else
    if (landMassInput == 3) {landMassInputS = "N.America"} else
      if (landMassInput == 4) {landMassInputS = "Europe"} else
        if (landMassInput == 5) {landMassInputS = "Asia"} else
          if (landMassInput == 6) {landMassInputS = "Africa"} 
  #convert user input to correct area value
areaInputS <- 10^areaInput - 1

#create user selection and convert into factor variable
sel <- data.frame("Catholic",landMassInputS,areaInputS)
names(sel) <- c("religion","landmass","area")
sel$religion <- factor(sel$religion, levels=c("Buddhist","Catholic","Christian","Ethnic","Hindu","Marxist","Muslim","Others"))
sel$landmass <- factor(sel$landmass, levels=c("Africa","Asia","Europe","N.America","Oceania","S.America"))
testing2 <- rbind(sel, testing)

#predict output
rfPred2 <- predict(rfMod, newdata = testing2)
#confusionMatrix(testing2$religion, rfPred2)
testing2$predicted <- testing2$religion == rfPred2
testing2$predicted[testing2$predicted==FALSE] <- "Wrong prediction"
testing2$predicted[testing2$predicted==TRUE] <- "Correct prediction"

#get the result for the user input
res <- rfPred2[1]
as.character(res)
}

predictReligionPlot <- function(landMassInput, areaInput){
  #this function performs the same code as above, except it plots the output
  #for more detailed comments, refer to the function above
  if (landMassInput == 1) {landMassInputS = "S.America"} else
    if (landMassInput == 2) {landMassInputS = "Oceania"} else
      if (landMassInput == 3) {landMassInputS = "N.America"} else
        if (landMassInput == 4) {landMassInputS = "Europe"} else
          if (landMassInput == 5) {landMassInputS = "Asia"} else
            if (landMassInput == 6) {landMassInputS = "Africa"} 
  areaInputS <- 10^areaInput - 1
  sel <- data.frame("Catholic",landMassInputS,areaInputS)
  names(sel) <- c("religion","landmass","area")
  sel$religion <- factor(sel$religion, levels=c("Buddhist","Catholic","Christian","Ethnic","Hindu","Marxist","Muslim","Others"))
  sel$landmass <- factor(sel$landmass, levels=c("Africa","Asia","Europe","N.America","Oceania","S.America"))
  
  testing2 <- rbind(sel, testing)
  rfPred2 <- predict(rfMod, newdata = testing2)
  #confusionMatrix(testing2$religion, rfPred2)
  testing2$predicted <- testing2$religion == rfPred2
  testing2$predicted[testing2$predicted==FALSE] <- "Wrong prediction"
  testing2$predicted[testing2$predicted==TRUE] <- "Correct prediction"
  
  pl <- qplot(x=log10(area+1), y=landmass, data=testing2[-1,], colour=religion, shape=predicted, size = 2)
  pl + geom_point(aes(x=log10(testing2[1,c("area")][[1]]+1), y=testing2[1,c("landmass")][[1]] ,color=rfPred2[1] , shape="Selection"), size=10) + xlab("area (log10scale)") 
}


shinyServer(
  function(input, output) {
    output$prediction <- renderPrint({predictReligion(input$LandMass, input$Area)})
    output$newPlot <- renderPlot({predictReligionPlot(input$LandMass, input$Area)})
  }
)