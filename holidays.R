
is.pos.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  {
  abs(x - round(x)) < tol & x > 0
}


#' support function for holiday get_us_holidays
#' @description takes in a function from the timeDate package that returns holidays a returns
#'  a dataframe with dates and labels
#' @author Isaac Wagner
#' @param holi_day the timeDate function that returns dates for US holidays
#' @inheritParams get_us_holidays
#' @return dataframe with two columns: date and holiday name

holiday_helper <- function(holi_day, begin_year, end_year) {
  temp <- as.data.frame(as.Date(eval(substitute(holi_day(begin_year:end_year)))))
  temp <- cbind(temp, as.character(substitute(holi_day))[3])
  names(temp) <- c("date", "holidays")
  return(temp)
}

#' US Holiday Dates
#' @description returns a dataframe of holidays, days where clinics may be closed due to holiday.  Defaults are 1980 and the current year.
#' @param begin_year the year (integer) you want to start getting holidays for
#' @param end_year the year (integer) you want to stop getting holdays for
#' @return a dataframe with two columns: date and holiday name
#' @export

get_us_holidays <- function(begin_year = 1980, end_year = NULL) {
  if (is.null(end_year)) {
    end_year <- as.integer(strftime(Sys.Date(), format = "%Y"))
  }
  if (!is.pos.wholenumber(begin_year)) {
    stop("Error: begin_year is not a whole number")
  }
  if (!is.pos.wholenumber(end_year)) {
    stop("Error: end_year is not a whole number")
  }
  if (end_year < begin_year) {
    stop("Error: end_year less than begin year")
  }


  holidays <- rbind(
    holiday_helper(timeDate::USNewYearsDay, begin_year, end_year),
    holiday_helper(timeDate::USMemorialDay, begin_year, end_year),
    holiday_helper(timeDate::USIndependenceDay, begin_year, end_year),
    holiday_helper(timeDate::USLaborDay, begin_year, end_year),
    holiday_helper(timeDate::USThanksgivingDay, begin_year, end_year),
    holiday_helper(timeDate::USChristmasDay, begin_year, end_year)
  )

  holidays[weekdays(holidays$date) == "Saturday", ]$date <- holidays[weekdays(holidays$date) == "Saturday", ]$date - 1
  holidays[weekdays(holidays$date) == "Sunday", ]$date <- holidays[weekdays(holidays$date) == "Sunday", ]$date + 1

  colnames(holidays) <- c("ds", "holiday") # prophet convention

  holidays %>%
    mutate(ds = ds %>% ymd() %>% as.POSIXct()) # prophet datatype
}
