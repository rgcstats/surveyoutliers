#' optimal.onesided.cutoff
#'
#' This function calculates optimal one-sided cutoffs for winsorization
#' where regression residuals are truncated at Q / (weight-1)
#' and Q satisfies the optimality result in Kokic and Bell (1994) and Clark (1995).
#' @param formula The regression formula (e.g. income ~ employment + old.turnover if income is survey variable and employment and old.turnover are auxiliary variables).
#' @param surveydata A data frame of the survey data including the variables in formula, piwt (inverse probability of selection) and gregwt (generalized regression estimator weight).
#' @param historical.reweight A set of reweighting factors for use when a historical dataset is being used.
#' It reweights from the historical sample to the sample of interest.
#' The default value of 1 should be used if the sample being used for optimising Q is the
#' same sample (or at least the same design) as the sample to which the winsorizing cutoffs are to be applied.
#' @param stop Set to T to open a browser window (for debugging purposes)
#' @return A list consisting of Q.opt (the optimal Q), rlm.coef (the robust regression coefficients),
#' cutoffs (the winsorizing cutoffs for each unit in sample), y (the values of the variable of interest),
#' win1.values (the type 1 winsorized values of interest, i.e. the minimums of the cutoff and y)
#' win2.values (the type 2 winsorized values of interest, so that sum(surveydata$gregwt*win2.values) is the winsorized estimator)
#' @references
#' Clark, R. G. (1995), "Winsorisation methods in sample surveys," Masters thesis, Australian National University, http://hdl.handle.net/10440/1031.
#'
#' Kokic, P. and Bell, P. (1994), "Optimal winsorizing cutoffs for a stratified finite population estimator," J. Off. Stat., 10, 419–435.
#' @examples
#' test <- optimal.onesided.cutoff(formula=y~x1+x2,surveydata=survdat.example)
#' plot(test$y,test$win1.values)

optimal.onesided.cutoff <- function(formula,surveydata,historical.reweight=1,stop=F){
  # firstly define the function to be zeroed numerically
  if(stop) browser()
  diff.fn <- function(Q,formula,surveydata,return.all=F,stop=F){
    if(stop) browser()
    rlm.results <- robust.lm.onesided( formula=formula , Q=Q , data=surveydata ,maxit=500 )
    lm.results <-  lm( formula=formula , weights=piwt , data=surveydata )
    bias.est <- sum(historical.reweight*(surveydata$gregwt-1)*(rlm.results$fitted.values-lm.results$fitted.values))
    out <- Q + bias.est
    if(return.all) out <- list( diff=Q+bias.est , rlm.results=rlm.results , lm.results=lm.results , Q=Q )
    out
  }
  formula.items <- as.character(formula)
  y <- surveydata[,formula.items[2]]
  Q.opt <- uniroot( f=diff.fn , formula=formula , surveydata=surveydata , interval=pmax(0.0001,range((y-median(y))*(surveydata$gregwt-1))) , return.all=F )$root
  full.results <- diff.fn( Q=Q.opt , formula=formula , surveydata=surveydata , return.all=T )
  cutoffs <- full.results$rlm.results$fitted.values + Q.opt / (surveydata$gregwt-1)
  win1.values <- pmin(y,cutoffs)
  win2.values <- ( y + win1.values * (surveydata$gregwt-1) ) / surveydata$gregwt
  list( Q.opt=Q.opt , rlm.coef=full.results$rlm.results$coef , cutoffs=cutoffs , y=y , win1.values=win1.values ,
        win2.values=win2.values )
}
