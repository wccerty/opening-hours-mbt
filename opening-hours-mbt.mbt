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
/// A recurring month/day range. Month 0 denotes any month for day-only ranges.
pub(all) struct MonthDayRange {
  start_month : Int32
  start_day : Int32
  end_month : Int32
  end_day : Int32
}

///|
pub(all) enum HolidayKind {
  PublicHoliday
  SchoolHoliday
}

///|
/// Explicit local holiday dates used by PH and SH rules.
pub(all) struct HolidayCalendar {
  public_holidays : Array[Date]
  school_holidays : Array[Date]
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
  months : Array[Int32]
  dates : Array[MonthDayRange]
  holidays : Array[HolidayKind]
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
fn month_code(value : String, position : Int32) -> Result[Int32, ParseError] {
  match value {
    "Jan" => Ok(1)
    "Feb" => Ok(2)
    "Mar" => Ok(3)
    "Apr" => Ok(4)
    "May" => Ok(5)
    "Jun" => Ok(6)
    "Jul" => Ok(7)
    "Aug" => Ok(8)
    "Sep" => Ok(9)
    "Oct" => Ok(10)
    "Nov" => Ok(11)
    "Dec" => Ok(12)
    _ => Err(parse_error("未知月份缩写", position))
  }
}

///|
fn is_month_word(value : String) -> Bool {
  if value.length() < 3 {
    return false
  }
  match month_code(value[:3].to_owned(), 0) {
    Ok(_) => true
    Err(_) => false
  }
}

///|
fn add_month(months : Array[Int32], month : Int32) -> Unit {
  let mut found = false
  for existing in months {
    if existing == month {
      found = true
    }
  }
  if !found {
    months.push(month)
  }
}

///|
fn parse_months(
  value : String,
  position : Int32,
) -> Result[Array[Int32], ParseError] {
  let months : Array[Int32] = []
  let mut part_offset = 0
  for part_view in value.split(",") {
    let part = part_view.to_owned()
    let dash = find_char(part, '-')
    if dash < 0 {
      match month_code(part, position + part_offset) {
        Ok(month) => add_month(months, month)
        Err(error) => return Err(error)
      }
    } else {
      if find_char(part[dash + 1:].to_owned(), '-') >= 0 {
        return Err(
          parse_error(
            "月份范围只能包含一个连字符",
            position + part_offset + dash,
          ),
        )
      }
      let first = match
        month_code(part[:dash].to_owned(), position + part_offset) {
        Ok(month) => month
        Err(error) => return Err(error)
      }
      let last = match
        month_code(
          part[dash + 1:].to_owned(),
          position + part_offset + dash + 1,
        ) {
        Ok(month) => month
        Err(error) => return Err(error)
      }
      let mut month = first
      let mut count = 0
      while count < 12 {
        add_month(months, month)
        if month == last {
          break
        }
        month = month % 12 + 1
        count += 1
      }
    }
    part_offset += part.length() + 1
  }
  Ok(months)
}

///|
fn parse_day_number(
  value : String,
  position : Int32,
) -> Result[Int32, ParseError] {
  let chars = value.to_array()
  if chars.length() < 1 || chars.length() > 2 {
    return Err(
      parse_error("日期中的日必须是一位或两位数字", position),
    )
  }
  let mut day = 0
  for ch in chars {
    if ch < '0' || ch > '9' {
      return Err(parse_error("日期中的日只能包含数字", position))
    }
    day = day * 10 + ch.to_int() - 48
  }
  if day < 1 || day > 31 {
    return Err(
      parse_error("日期中的日必须在 1 到 31 之间", position),
    )
  }
  Ok(day)
}

///|
fn is_day_range_token(value : String) -> Bool {
  let chars = value.to_array()
  if chars.length() == 0 {
    return false
  }
  for ch in chars {
    if (ch < '0' || ch > '9') && ch != '-' {
      return false
    }
  }
  true
}

///|
fn parse_day_range(
  value : String,
  month : Int32,
  position : Int32,
) -> Result[MonthDayRange, ParseError] {
  let dash = find_char(value, '-')
  let start_day = if dash < 0 {
    match parse_day_number(value, position) {
      Ok(day) => day
      Err(error) => return Err(error)
    }
  } else {
    if find_char(value[dash + 1:].to_owned(), '-') >= 0 {
      return Err(
        parse_error("日期范围只能包含一个连字符", position + dash),
      )
    }
    match parse_day_number(value[:dash].to_owned(), position) {
      Ok(day) => day
      Err(error) => return Err(error)
    }
  }
  let end_day = if dash < 0 {
    start_day
  } else {
    match parse_day_number(value[dash + 1:].to_owned(), position + dash + 1) {
      Ok(day) => day
      Err(error) => return Err(error)
    }
  }
  let month_filter = if month == 0 { 0 } else { month }
  Ok({ start_month: month_filter, start_day, end_month: month_filter, end_day, })
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

  let first_position = base_position + start
  let weekdays : Array[Int32] = []
  let months : Array[Int32] = []
  let dates : Array[MonthDayRange] = []
  let holidays : Array[HolidayKind] = []
  let times : Array[TimeRange] = []
  let mut state = RuleState::Open
  let mut has_time = false
  let mut cursor = start
  while cursor < end {
    while cursor < end && is_space(chars[cursor]) {
      cursor += 1
    }
    if cursor < end {
      let token_start = cursor
      while cursor < end && !is_space(chars[cursor]) {
        cursor += 1
      }
      let raw_token = value[token_start:cursor].to_owned()
      let token_position = base_position + token_start
      let token = if raw_token.length() > 0 &&
        raw_token[raw_token.length() - 1] == ':' {
        raw_token[:raw_token.length() - 1].to_owned()
      } else {
        raw_token
      }
      if token == "open" {
        state = RuleState::Open
      } else if token == "off" || token == "closed" {
        state = RuleState::Closed
      } else if token == "24/7" {
        if has_time {
          return Err(
            parse_error("同一规则不能重复指定时段", token_position),
          )
        }
        times.push({ start_minute: 0, end_minute: 1440, })
        has_time = true
      } else if find_char(token, ':') >= 0 {
        match parse_times(token, token_position) {
          Ok(parsed) =>
            for time in parsed {
              times.push(time)
            }
          Err(error) => return Err(error)
        }
        has_time = true
      } else if token == "PH" {
        if has_time {
          return Err(
            parse_error(
              "日期选择器必须位于时段之前", token_position,
            ),
          )
        }
        holidays.push(HolidayKind::PublicHoliday)
      } else if token == "SH" {
        if has_time {
          return Err(
            parse_error(
              "日期选择器必须位于时段之前", token_position,
            ),
          )
        }
        holidays.push(HolidayKind::SchoolHoliday)
      } else if is_weekday_word(token) {
        if has_time {
          return Err(
            parse_error(
              "日期选择器必须位于时段之前", token_position,
            ),
          )
        }
        match parse_weekdays(token, token_position) {
          Ok(parsed) =>
            for day in parsed {
              add_weekday(weekdays, day)
            }
          Err(error) => return Err(error)
        }
      } else if is_month_word(token) {
        if has_time {
          return Err(
            parse_error(
              "日期选择器必须位于时段之前", token_position,
            ),
          )
        }
        match parse_months(token, token_position) {
          Ok(parsed) =>
            for month in parsed {
              add_month(months, month)
            }
          Err(error) => return Err(error)
        }
      } else if find_char(token, '-') >= 0 &&
        is_month_word(token[find_char(token, '-') + 1:].to_owned()) {
        if has_time || months.length() == 0 {
          return Err(
            parse_error("跨月日期范围需要前置月份", token_position),
          )
        }
        let dash = find_char(token, '-')
        let start_day = match
          parse_day_number(token[:dash].to_owned(), token_position) {
          Ok(day) => day
          Err(error) => return Err(error)
        }
        let end_month_name = token[dash + 1:].to_owned()
        let end_month = match
          month_code(end_month_name, token_position + dash + 1) {
          Ok(month) => month
          Err(error) => return Err(error)
        }
        while cursor < end && is_space(chars[cursor]) {
          cursor += 1
        }
        let end_day_start = cursor
        while cursor < end && !is_space(chars[cursor]) {
          cursor += 1
        }
        if end_day_start == cursor {
          return Err(
            parse_error(
              "跨月日期范围缺少结束日",
              base_position + cursor,
            ),
          )
        }
        let end_day_token = value[end_day_start:cursor].to_owned()
        let end_day_token = if end_day_token.length() > 0 &&
          end_day_token[end_day_token.length() - 1] == ':' {
          end_day_token[:end_day_token.length() - 1].to_owned()
        } else {
          end_day_token
        }
        let end_day = match
          parse_day_number(end_day_token, base_position + end_day_start) {
          Ok(day) => day
          Err(error) => return Err(error)
        }
        let start_month = if months.length() == 1 { months[0] } else { 0 }
        dates.push({ start_month, start_day, end_month, end_day, })
        months.clear()
      } else if token.length() > 0 &&
        token[0] >= '0' &&
        token[0] <= '9' &&
        is_day_range_token(token) {
        if has_time || months.length() == 0 {
          return Err(
            parse_error(
              "月日范围必须跟在月份选择器之后", token_position,
            ),
          )
        }
        let month = if months.length() == 1 { months[0] } else { 0 }
        match parse_day_range(token, month, token_position) {
          Ok(date_range) => dates.push(date_range)
          Err(error) => return Err(error)
        }
      } else {
        let begins_with_letter = token.length() > 0 &&
          (
            (token[0] >= 'a' && token[0] <= 'z') ||
            (token[0] >= 'A' && token[0] <= 'Z')
          )
        let message = if begins_with_letter {
          "规则中存在无法识别的词"
        } else {
          "不支持或无法识别的规则选择器"
        }
        return Err(parse_error(message, token_position))
      }
    }
  }

  if !has_time {
    match state {
      RuleState::Open => times.push({ start_minute: 0, end_minute: 1440, })
      RuleState::Closed => ()
    }
  }
  Ok({
    weekdays,
    months,
    dates,
    holidays,
    times,
    state,
    position: first_position,
  })
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
