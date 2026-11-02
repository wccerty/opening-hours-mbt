///|
/// The opening intervals for one calendar day.
pub(all) struct DailySchedule {
  date : Date
  periods : Array[TimeRange]
}

///|
fn rule_matches_weekday(rule : Rule, date : Date) -> Bool {
  if rule.weekdays.length() == 0 {
    return true
  }
  let weekday = weekday_of_date(date)
  for selected in rule.weekdays {
    if selected == weekday {
      return true
    }
  }
  false
}

///|
fn normalize_intervals(intervals : Array[TimeRange]) -> Array[TimeRange] {
  for i in 1..<intervals.length() {
    let key = intervals[i]
    let mut j = i
    while j > 0 && intervals[j - 1].start_minute > key.start_minute {
      intervals[j] = intervals[j - 1]
      j -= 1
    }
    intervals[j] = key
  }
  let merged : Array[TimeRange] = []
  for interval in intervals {
    if merged.length() == 0 {
      merged.push(interval)
    } else {
      let last_index = merged.length() - 1
      let previous = merged[last_index]
      if interval.start_minute <= previous.end_minute {
        if interval.end_minute > previous.end_minute {
          merged[last_index] = {
            start_minute: previous.start_minute,
            end_minute: interval.end_minute,
          }
        }
      } else {
        merged.push(interval)
      }
    }
  }
  merged
}

///|
fn subtract_interval(
  intervals : Array[TimeRange],
  cut : TimeRange,
) -> Array[TimeRange] {
  let remaining : Array[TimeRange] = []
  for interval in intervals {
    if cut.end_minute <= interval.start_minute ||
      cut.start_minute >= interval.end_minute {
      remaining.push(interval)
    } else {
      if cut.start_minute > interval.start_minute {
        remaining.push({
          start_minute: interval.start_minute,
          end_minute: cut.start_minute,
        })
      }
      if cut.end_minute < interval.end_minute {
        remaining.push({
          start_minute: cut.end_minute,
          end_minute: interval.end_minute,
        })
      }
    }
  }
  remaining
}

///|
fn intervals_for_date(
  expr : Expr,
  date : Date,
  depth : Int32,
) -> Array[TimeRange] {
  let intervals : Array[TimeRange] = []
  if depth < 2 {
    let previous = intervals_for_date(expr, add_days(date, -1), depth + 1)
    for interval in previous {
      if interval.end_minute > 1440 {
        intervals.push({
          start_minute: interval.start_minute - 1440,
          end_minute: interval.end_minute - 1440,
        })
      }
    }
  }
  for rule in expr.rules {
    if rule_matches_weekday(rule, date) {
      match rule.state {
        RuleState::Open => {
          intervals.clear()
          for time in rule.times {
            intervals.push(time)
          }
        }
        RuleState::Closed =>
          if rule.times.length() == 0 {
            intervals.clear()
          } else {
            for time in rule.times {
              let remaining = subtract_interval(intervals, time)
              intervals.clear()
              for interval in remaining {
                intervals.push(interval)
              }
            }
          }
      }
    }
  }
  normalize_intervals(intervals)
}

///|
fn is_open_unchecked(expr : Expr, datetime : DateTime) -> Bool {
  let minute = datetime.hour * 60 + datetime.minute
  let intervals = intervals_for_date(expr, datetime.date, 0)
  for interval in intervals {
    if minute >= interval.start_minute && minute < interval.end_minute {
      return true
    }
  }
  false
}

///|
fn has_no_open_rules(expr : Expr) -> Bool {
  for rule in expr.rules {
    if rule.state is RuleState::Open {
      return false
    }
  }
  true
}

///|
fn is_universally_open(expr : Expr) -> Bool {
  if expr.rules.length() != 1 {
    return false
  }
  let rule = expr.rules[0]
  if !(rule.state is RuleState::Open) || rule.times.length() != 1 {
    return false
  }
  if rule.weekdays.length() != 0 && rule.weekdays.length() != 7 {
    return false
  }
  rule.times[0].start_minute == 0 && rule.times[0].end_minute == 1440
}

///|
/// Check whether a local wall-clock time falls inside an opening interval.
pub fn is_open(
  expr : Expr,
  datetime : DateTime,
) -> Result[Bool, EvaluationError] {
  if !is_valid_datetime(datetime) {
    return Err({ message: "本地日期时间无效", })
  }
  Ok(is_open_unchecked(expr, datetime))
}

///|
/// Return the first minute when the open/closed state differs from `datetime`.
/// The search covers 370 days; a schedule with no observable change returns `None`.
pub fn next_change(
  expr : Expr,
  datetime : DateTime,
) -> Result[DateTime?, EvaluationError] {
  if !is_valid_datetime(datetime) {
    return Err({ message: "本地日期时间无效", })
  }
  if has_no_open_rules(expr) || is_universally_open(expr) {
    return Ok(None)
  }
  let initial_state = is_open_unchecked(expr, datetime)
  let mut cursor = datetime
  let mut step = 0
  let limit = 370 * 1440
  while step < limit {
    cursor = add_minutes(cursor, 1)
    if is_open_unchecked(expr, cursor) != initial_state {
      return Ok(Some(cursor))
    }
    step += 1
  }
  Ok(None)
}

///|
/// Return the opening intervals clipped to one local calendar day.
pub fn opening_periods_for_day(
  expr : Expr,
  date : Date,
) -> Result[Array[TimeRange], EvaluationError] {
  if !is_valid_date(date) {
    return Err({
      message: "日期无效；年份需大于 1900，且日期必须存在",
    })
  }
  let periods : Array[TimeRange] = []
  for interval in intervals_for_date(expr, date, 0) {
    if interval.start_minute < 1440 && interval.end_minute > 0 {
      let start = if interval.start_minute < 0 {
        0
      } else {
        interval.start_minute
      }
      let end = if interval.end_minute > 1440 {
        1440
      } else {
        interval.end_minute
      }
      if start < end {
        periods.push({ start_minute: start, end_minute: end, })
      }
    }
  }
  Ok(normalize_intervals(periods))
}

///|
/// Return seven daily schedules beginning on a Monday.
pub fn opening_periods_for_week(
  expr : Expr,
  monday : Date,
) -> Result[Array[DailySchedule], EvaluationError] {
  if !is_valid_date(monday) {
    return Err({
      message: "日期无效；年份需大于 1900，且日期必须存在",
    })
  }
  if weekday_of_date(monday) != 0 {
    return Err({ message: "周起始日期必须是星期一", })
  }
  let schedules : Array[DailySchedule] = []
  for offset in 0..<7 {
    let date = add_days(monday, offset)
    match opening_periods_for_day(expr, date) {
      Ok(periods) => schedules.push({ date, periods, })
      Err(error) => return Err(error)
    }
  }
  Ok(schedules)
}
