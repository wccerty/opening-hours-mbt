///|
/// An error raised when a date or local time is invalid.
pub(all) struct EvaluationError {
  message : String
}

///|
fn month_length(year : Int32, month : Int32) -> Int32 {
  match month {
    2 => if is_leap_year(year) { 29 } else { 28 }
    4 | 6 | 9 | 11 => 30
    _ => 31
  }
}

///|
fn is_leap_year(year : Int32) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

///|
fn is_valid_date(date : Date) -> Bool {
  date.year >= 1901 &&
  date.month >= 1 &&
  date.month <= 12 &&
  date.day >= 1 &&
  date.day <= month_length(date.year, date.month)
}

///|
fn is_valid_datetime(datetime : DateTime) -> Bool {
  is_valid_date(datetime.date) &&
  datetime.hour >= 0 &&
  datetime.hour <= 23 &&
  datetime.minute >= 0 &&
  datetime.minute <= 59
}

///|
/// Construct a validated Gregorian calendar date.
pub fn new_date(
  year : Int32,
  month : Int32,
  day : Int32,
) -> Result[Date, EvaluationError] {
  let date = { year, month, day, }
  if is_valid_date(date) {
    Ok(date)
  } else {
    Err({
      message: "日期无效；年份需大于 1900，且日期必须存在",
    })
  }
}

///|
/// Construct a validated local wall-clock time.
pub fn new_datetime(
  date : Date,
  hour : Int32,
  minute : Int32,
) -> Result[DateTime, EvaluationError] {
  let datetime = { date, hour, minute, }
  if is_valid_datetime(datetime) {
    Ok(datetime)
  } else {
    Err({ message: "本地日期时间无效", })
  }
}

///|
/// Return the weekday number, where Monday is 0 and Sunday is 6.
pub fn weekday_of_date(date : Date) -> Int32 {
  let adjusted_month = if date.month <= 2 {
    date.month + 12
  } else {
    date.month
  }
  let adjusted_year = if date.month <= 2 { date.year - 1 } else { date.year }
  let year_of_century = adjusted_year % 100
  let century = adjusted_year / 100
  let zeller = (
      date.day +
      13 * (adjusted_month + 1) / 5 +
      year_of_century +
      year_of_century / 4 +
      century / 4 +
      5 * century
    ) %
    7
  (zeller + 5) % 7
}

///|
fn add_days(date : Date, delta : Int32) -> Date {
  let mut year = date.year
  let mut month = date.month
  let mut day = date.day
  let mut remaining = delta
  while remaining > 0 {
    let available = month_length(year, month) - day
    if remaining <= available {
      day += remaining
      remaining = 0
    } else {
      remaining -= available + 1
      day = 1
      if month == 12 {
        month = 1
        year += 1
      } else {
        month += 1
      }
    }
  }
  while remaining < 0 {
    if -remaining < day {
      day += remaining
      remaining = 0
    } else {
      remaining += day
      if month == 1 {
        month = 12
        year -= 1
      } else {
        month -= 1
      }
      day = month_length(year, month)
    }
  }
  { year, month, day, }
}

///|
fn add_minutes(datetime : DateTime, delta : Int32) -> DateTime {
  let total = datetime.hour * 60 + datetime.minute + delta
  let day_delta = if total >= 0 { total / 1440 } else { (total - 1439) / 1440 }
  let minute_of_day = total - day_delta * 1440
  {
    date: add_days(datetime.date, day_delta),
    hour: minute_of_day / 60,
    minute: minute_of_day % 60,
  }
}
