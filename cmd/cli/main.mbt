///|
fn digit(ch : Char) -> Int32? {
  if ch >= '0' && ch <= '9' {
    Some(ch.to_int() - 48)
  } else {
    None
  }
}

///|
fn parse_number(chars : Array[Char], start : Int32, end : Int32) -> Int32? {
  let mut value = 0
  for index in start..<end {
    match digit(chars[index]) {
      Some(number) => value = value * 10 + number
      None => return None
    }
  }
  Some(value)
}

///|
fn parse_datetime(value : String) -> @opening_hours.DateTime? {
  let chars = value.to_array()
  if chars.length() != 16 ||
    chars[4] != '-' ||
    chars[7] != '-' ||
    chars[10] != 'T' ||
    chars[13] != ':' {
    return None
  }
  let year = match parse_number(chars, 0, 4) {
    Some(number) => number
    None => return None
  }
  let month = match parse_number(chars, 5, 7) {
    Some(number) => number
    None => return None
  }
  let day = match parse_number(chars, 8, 10) {
    Some(number) => number
    None => return None
  }
  let hour = match parse_number(chars, 11, 13) {
    Some(number) => number
    None => return None
  }
  let minute = match parse_number(chars, 14, 16) {
    Some(number) => number
    None => return None
  }
  let date = match @opening_hours.new_date(year, month, day) {
    Ok(date) => date
    Err(_) => return None
  }
  match @opening_hours.new_datetime(date, hour, minute) {
    Ok(datetime) => Some(datetime)
    Err(_) => None
  }
}

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
fn main {
  let args = @env.args()
  if args.length() != 3 {
    println("用法：opening-hours <表达式> <YYYY-MM-DDTHH:MM>")
    println(
      "示例：moon run cmd/cli --target native \"Mo-Fr 09:00-18:00\" 2026-11-02T10:30",
    )
    return
  }
  let expression = match @opening_hours.parse(args[1]) {
    Ok(expression) => expression
    Err(error) => {
      println(
        "表达式错误（位置 \{error.position}）：\{error.message}",
      )
      return
    }
  }
  let datetime = match parse_datetime(args[2]) {
    Some(datetime) => datetime
    None => {
      println("时间格式无效；请使用 YYYY-MM-DDTHH:MM 的本地时间")
      return
    }
  }
  match @opening_hours.is_open(expression, datetime) {
    Ok(is_open) =>
      println(
        "营业状态：\{if is_open { "营业中" } else { "已关闭" }}",
      )
    Err(error) => println("求值错误：\{error.message}")
  }
  match @opening_hours.next_change(expression, datetime) {
    Ok(Some(next)) => println("下次状态变化：\{format_datetime(next)}")
    Ok(None) =>
      println("下次状态变化：无（搜索窗口内状态不变）")
    Err(error) => println("求值错误：\{error.message}")
  }
}
