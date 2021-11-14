# Paper Repository: Automatic Forecasting of Radiology Examination Volume Trends for Optimal Resource Planning and Allocation

  <!-- badges: start -->
  [![Launch Rstudio Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ASBecker/exam_forecast/master?urlpath=rstudio)
  [![DOI](https://zenodo.org/badge/245634463.svg)](https://zenodo.org/badge/latestdoi/245634463)
  <!-- badges: end -->

by
Anton S. Becker · Joseph P. Erinjeri · Joshua Chaim · Nicholas Kastango · Pierre Elnajjar · Hedvig Hricak · H. Alberto Vargas

This is the companion analysis to a paper published in the [Journal of Digital Imaging](https://doi.org/10.1007/s10278-021-00532-4).

## Preparation

To run the analysis in `ExamForecast.Rmd`, the following packages need to be installed:

```r
install.packages(
  c(
    "here",
    "kableExtra",
    "knitr",
    "magrittr",
    "prophet",
    "readr",
    "rmarkdown",
    "stringr",
    "tidyverse",
    "timeDate"
    # Recommended:
    "rticles"
    "skimr"
  )
)
```

## Data Format

The synthetic toy data is provided in the "Data" folder (gzipped csv). It can be read natively by `{{readr::read_csv}}` or alternatively unzipped by R's native `read.csv` function. To run a prophet forecast with our own data, replace the csv files with your own data with at least two columns: `Date` and `number of examinations`. 
In order to recycle the code from this repository a column `modality_code` should be added containing either "CT" or "MRI".

```r
library(dplyr)
here::here("Data", "per_diem_msk.csv.gz") %>%  
  readr::read_csv(show_col_types = FALSE) %>% 
  skimr::skim()
```

## Simple forecast example

For a more comprehensive documentation please refer to the accompanying `ExamForecast.Rmd` and the official Prophet documentation. Below is a minimal example of a forecast for the next month:

```r
library(dplyr)
library(prophet)

exams <- here::here("Data", "per_diem_msk.csv.gz") %>% 
  readr::read_csv() %>%
  filter(modality_code == "CT") %>% 
  transmute(
    ds = as_date(exam_date),
    y = n_exams,
  )

m <- prophet(exams)

pred <- make_future_dataframe(m, 31, "days", include_history = TRUE)

forecast_exams <- predict(m, pred)
```

## License

All source code is made available under a MIT or file-specific license. You can freely
use and modify the code, without warranty, so long as you provide attribution
to the authors/[cite the article](https://doi.org/10.1007/s10278-021-00532-4). See `LICENSE.md` for the full license text.
