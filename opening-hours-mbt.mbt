///|
/// A calendar date in the local calendar used by an opening-hours expression.
pub(all) struct Date {
  year : Int32
  month : Int32
  day : Int32
}

///|
/// A local wall-clock date and time. No system time zone is applied.
pub(all) struct DateTime {
  date : Date
  hour : Int32
  minute : Int32
}

///|
/// A time interval in minutes from the beginning of its start date.
/// `end_minute` may exceed 1440 for an interval that passes midnight.
pub(all) struct TimeRange {
  start_minute : Int32
  end_minute : Int32
}

///|
pub(all) enum RuleState {
  Open
  Closed
}

///|
/// One semicolon-separated OSM rule.
pub(all) struct Rule {
  weekdays : Array[Int32]
  times : Array[TimeRange]
  state : RuleState
  position : Int32
}

///|
/// Parsed opening-hours expression.
pub(all) struct Expr {
  rules : Array[Rule]
}

///|
/// A parse failure with a zero-based position in the source expression.
pub(all) struct ParseError {
  message : String
  position : Int32
}

///|
fn parse_error(message : String, position : Int32) -> ParseError {
  { message, position, }
}

///|
fn is_space(ch : Char) -> Bool {
  ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n'
}

///|
fn find_char(value : String, needle : Char) -> Int32 {
  let chars = value.to_array()
  for i in 0..<chars.length() {
    if chars[i] == needle {
      return i
    }
  }
  -1
}

///|
fn weekday_code(value : String, position : Int32) -> Result[Int32, ParseError] {
  let chars = value.to_array()
  if chars.length() != 2 {
    return Err(parse_error("星期必须使用两个字母缩写", position))
  }
  match (chars[0], chars[1]) {
    ('M', 'o') => Ok(0)
    ('T', 'u') => Ok(1)
    ('W', 'e') => Ok(2)
    ('T', 'h') => Ok(3)
    ('F', 'r') => Ok(4)
    ('S', 'a') => Ok(5)
    ('S', 'u') => Ok(6)
    _ => Err(parse_error("未知星期缩写", position))
  }
}

///|
fn add_weekday(days : Array[Int32], day : Int32) -> Unit {
  let mut found = false
  for existing in days {
    if existing == day {
      found = true
    }
  }
  if !found {
    days.push(day)
  }
}

///|
fn parse_weekdays(
  value : String,
  position : Int32,
) -> Result[Array[Int32], ParseError] {
  let days : Array[Int32] = []
  let mut part_offset = 0
  for part_view in value.split(",") {
    let part = part_view.to_owned()
    let dash = find_char(part, '-')
    if dash < 0 {
      match weekday_code(part, position + part_offset) {
        Ok(day) => add_weekday(days, day)
        Err(error) => return Err(error)
      }
    } else {
      if find_char(part[dash + 1:].to_owned(), '-') >= 0 {
        return Err(
          parse_error(
            "星期范围只能包含一个连字符",
            position + part_offset + dash,
          ),
        )
      }
      let first = part[:dash].to_owned()
      let last = part[dash + 1:].to_owned()
      let from = match weekday_code(first, position + part_offset) {
        Ok(day) => day
        Err(error) => return Err(error)
      }
      let to = match weekday_code(last, position + part_offset + dash + 1) {
        Ok(day) => day
        Err(error) => return Err(error)
      }
      let mut day = from
      let mut count = 0
      while count < 7 {
        add_weekday(days, day)
        if day == to {
          break
        }
        day = (day + 1) % 7
        count += 1
      }
    }
    part_offset += part.length() + 1
  }
  if days.length() == 0 {
    return Err(parse_error("星期选择器不能为空", position))
  }
  Ok(days)
}

///|
fn parse_time(
  value : String,
  position : Int32,
  is_end : Bool,
) -> Result[Int32, ParseError] {
  let chars = value.to_array()
  if chars.length() != 5 || chars[2] != ':' {
    return Err(parse_error("时间必须采用 HH:MM 格式", position))
  }
  if chars[0] < '0' ||
    chars[0] > '9' ||
    chars[1] < '0' ||
    chars[1] > '9' ||
    chars[3] < '0' ||
    chars[3] > '9' ||
    chars[4] < '0' ||
    chars[4] > '9' {
    return Err(parse_error("时间只能包含数字和冒号", position))
  }
  let hour = (chars[0].to_int() - 48) * 10 + chars[1].to_int() - 48
  let minute = (chars[3].to_int() - 48) * 10 + chars[4].to_int() - 48
  let max_hour = if is_end { 48 } else { 24 }
  if minute > 59 || hour > max_hour || (hour == max_hour && minute != 0) {
    return Err(parse_error("时间超出允许范围", position))
  }
  Ok(hour * 60 + minute)
}

///|
fn parse_times(
  value : String,
  position : Int32,
) -> Result[Array[TimeRange], ParseError] {
  let times : Array[TimeRange] = []
  let mut item_offset = 0
  for item_view in value.split(",") {
    let item = item_view.to_owned()
    let dash = find_char(item, '-')
    if dash <= 0 || find_char(item[dash + 1:].to_owned(), '-') >= 0 {
      return Err(
        parse_error(
          "时段必须采用 HH:MM-HH:MM 格式",
          position + item_offset,
        ),
      )
    }
    let start = match
      parse_time(item[:dash].to_owned(), position + item_offset, false) {
      Ok(minute) => minute
      Err(error) => return Err(error)
    }
    let mut end = match
      parse_time(
        item[dash + 1:].to_owned(),
        position + item_offset + dash + 1,
        true,
      ) {
      Ok(minute) => minute
      Err(error) => return Err(error)
    }
    if end == start {
      return Err(
        parse_error(
          "时段起止时间不能相同",
          position + item_offset + dash + 1,
        ),
      )
    }
    if end < start {
      end += 1440
    }
    times.push({ start_minute: start, end_minute: end, })
    item_offset += item.length() + 1
  }
  Ok(times)
}

///|
fn is_weekday_word(value : String) -> Bool {
  if value.length() < 2 {
    return false
  }
  let first = value[:2].to_owned()
  match weekday_code(first, 0) {
    Ok(_) => true
    Err(_) => false
  }
}

///|
fn parse_rule(
  value : String,
  base_position : Int32,
) -> Result[Rule, ParseError] {
  let chars = value.to_array()
  let mut start = 0
  let mut end = chars.length()
  while start < end && is_space(chars[start]) {
    start += 1
  }
  while end > start && is_space(chars[end - 1]) {
    end -= 1
  }
  if start == end {
    return Err(parse_error("规则不能为空", base_position + start))
  }

  let mut cursor = start
  while cursor < end && !is_space(chars[cursor]) {
    cursor += 1
  }
  let first = value[start:cursor].to_owned()
  let first_position = base_position + start
  let weekdays : Array[Int32] = []
  let times : Array[TimeRange] = []
  let mut state = RuleState::Open
  let mut has_time = false

  if first == "24/7" {
    times.push({ start_minute: 0, end_minute: 1440, })
    has_time = true
  } else if first == "off" || first == "closed" {
    state = RuleState::Closed
  } else if first == "open" {
    ()
  } else if is_weekday_word(first) {
    match parse_weekdays(first, first_position) {
      Ok(parsed) =>
        for day in parsed {
          add_weekday(weekdays, day)
        }
      Err(error) => return Err(error)
    }
  } else if find_char(first, ':') >= 0 {
    match parse_times(first, first_position) {
      Ok(parsed) =>
        for time in parsed {
          times.push(time)
        }
      Err(error) => return Err(error)
    }
    has_time = true
  } else {
    return Err(
      parse_error("不支持或无法识别的规则选择器", first_position),
    )
  }

  while cursor < end {
    while cursor < end && is_space(chars[cursor]) {
      cursor += 1
    }
    if cursor < end {
      let token_start = cursor
      while cursor < end && !is_space(chars[cursor]) {
        cursor += 1
      }
      let token = value[token_start:cursor].to_owned()
      let token_position = base_position + token_start
      if token == "open" {
        state = RuleState::Open
      } else if token == "off" || token == "closed" {
        state = RuleState::Closed
      } else if find_char(token, ':') >= 0 {
        match parse_times(token, token_position) {
          Ok(parsed) =>
            for time in parsed {
              times.push(time)
            }
          Err(error) => return Err(error)
        }
        has_time = true
      } else {
        return Err(
          parse_error("规则中存在无法识别的词", token_position),
        )
      }
    }
  }

  if !has_time {
    match state {
      RuleState::Open => times.push({ start_minute: 0, end_minute: 1440, })
      RuleState::Closed => ()
    }
  }
  Ok({ weekdays, times, state, position: first_position, })
}

///|
/// Parse an OSM `opening_hours` expression in the supported syntax subset.
///
/// The first release supports weekday selectors, time ranges, semicolon rules,
/// `24/7`, `off`, and `closed`. Unsupported syntax returns its source position.
pub fn parse(value : String) -> Result[Expr, ParseError] {
  let rules : Array[Rule] = []
  let chars = value.to_array()
  if chars.length() == 0 {
    return Err(parse_error("表达式不能为空", 0))
  }
  let mut start = 0
  for i in 0..<chars.length() {
    if chars[i] == ';' {
      let rule_text = value[start:i].to_owned()
      match parse_rule(rule_text, start) {
        Ok(rule) => rules.push(rule)
        Err(error) => return Err(error)
      }
      start = i + 1
    }
  }
  let last_rule = value[start:].to_owned()
  match parse_rule(last_rule, start) {
    Ok(rule) => rules.push(rule)
    Err(error) => return Err(error)
  }
  Ok({ rules, })
}
