///|
fn two_digits(value : Int32) -> String {
  if value < 10 {
    "0\{value}"
  } else {
    value.to_string()
  }
}

///|
fn format_datetime(datetime : @opening_hours.DateTime) -> String {
  "\{datetime.date.year}-\{two_digits(datetime.date.month)}-\{two_digits(datetime.date.day)}T\{two_digits(datetime.hour)}:\{two_digits(datetime.minute)}"
}

///|
fn number(chars : Array[Char], start : Int32, end : Int32) -> Int32? {
  let mut value = 0
  for index in start..<end {
    let ch = chars[index]
    if ch < '0' || ch > '9' {
      return None
    }
    value = value * 10 + ch.to_int() - 48
  }
  Some(value)
}

///|
fn parse_date(value : String) -> @opening_hours.Date? {
  let chars = value.to_array()
  if chars.length() != 10 || chars[4] != '-' || chars[7] != '-' {
    return None
  }
  let year = match number(chars, 0, 4) {
    Some(value) => value
    None => return None
  }
  let month = match number(chars, 5, 7) {
    Some(value) => value
    None => return None
  }
  let day = match number(chars, 8, 10) {
    Some(value) => value
    None => return None
  }
  match @opening_hours.new_date(year, month, day) {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn parse_datetime(value : String) -> @opening_hours.DateTime? {
  let chars = value.to_array()
  if chars.length() != 16 || chars[10] != 'T' || chars[13] != ':' {
    return None
  }
  let date = match parse_date(value[:10].to_owned()) {
    Some(value) => value
    None => return None
  }
  let hour = match number(chars, 11, 13) {
    Some(value) => value
    None => return None
  }
  let minute = match number(chars, 14, 16) {
    Some(value) => value
    None => return None
  }
  match @opening_hours.new_datetime(date, hour, minute) {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn parse_dates_csv(value : String) -> Array[@opening_hours.Date]? {
  let dates : Array[@opening_hours.Date] = []
  if value.length() == 0 {
    return Some(dates)
  }
  for date_text_view in value.split(",") {
    match parse_date(date_text_view.to_owned()) {
      Some(date) => dates.push(date)
      None => return None
    }
  }
  Some(dates)
}

///|
#export_name("evaluate")
pub fn evaluate(
  expression : String,
  local_datetime : String,
  public_holidays_csv : String,
  school_holidays_csv : String,
) -> String {
  let datetime = match parse_datetime(local_datetime) {
    Some(value) => value
    None =>
      return "时间格式无效；请使用 YYYY-MM-DDTHH:MM 的本地时间"
  }
  let expr = match @opening_hours.parse(expression) {
    Ok(value) => value
    Err(error) =>
      return "表达式错误（位置 \{error.position}）：\{error.message}"
  }
  let public_holidays = match parse_dates_csv(public_holidays_csv) {
    Some(value) => value
    None =>
      return "PH 日历格式无效；日期须为逗号分隔的 YYYY-MM-DD"
  }
  let school_holidays = match parse_dates_csv(school_holidays_csv) {
    Some(value) => value
    None =>
      return "SH 日历格式无效；日期须为逗号分隔的 YYYY-MM-DD"
  }
  let calendar : @opening_hours.HolidayCalendar = {
    public_holidays,
    school_holidays,
  }
  let state = match
    @opening_hours.is_open_with_calendar(expr, datetime, calendar) {
    Ok(true) => "营业中"
    Ok(false) => "已关闭"
    Err(error) => return "求值错误：\{error.message}"
  }
  match @opening_hours.next_change_with_calendar(expr, datetime, calendar) {
    Ok(Some(next)) => "\{state}\n下次状态变化：\{format_datetime(next)}"
    Ok(None) =>
      "\{state}\n下次状态变化：无（搜索窗口内状态不变）"
    Err(error) => "求值错误：\{error.message}"
  }
}
