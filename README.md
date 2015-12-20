<!-- README.md is generated from README.Rmd. Please edit that file -->
### surveyoutliers

This package contains various procedures to deal with outliers in survey data. The only method available at present is to calculate optimal winsorising cutoffs as described in Kokic and Bell (1994) and Clark (1995).

### Installation

``` r
library(devtools)
devtools::install_github("rgcstats/surveyoutliers")
```

### Quick demo

Calculates optimal tuning parameter and hence winsorised values via `optimal.onesided.cutoff()`. Then plots the winsorised vs the raw values of the variable of interest:

``` r
library(surveyoutliers)
test <- optimal.onesided.cutoff(formula=y~x1+x2,surveydata=survdat.example)
plot(test$windata$y,test$windata$win1.values)
```

![](README-unnamed-chunk-2-1.png)

#### References

Clark, R. G. (1995), "Winsorisation methods in sample surveys," Masters thesis, Australian National University, <http://hdl.handle.net/10440/1031>.

Kokic, P. and Bell, P. (1994), "Optimal winsorizing cutoffs for a stratified finite population estimator," J. Off. Stat., 10, 419-435.
