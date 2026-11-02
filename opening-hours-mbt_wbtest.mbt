///|
test "Gregorian weekdays match fixed calendar dates" {
  assert_eq(weekday_of_date({ year: 2026, month: 11, day: 2, }), 0)
  assert_eq(weekday_of_date({ year: 2024, month: 2, day: 29, }), 3)
  assert_eq(weekday_of_date({ year: 2000, month: 1, day: 1, }), 5)
}

///|
test "Date validation accepts leap day and rejects impossible dates" {
  assert_true(new_date(2024, 2, 29) is Ok(_))
  assert_true(new_date(2023, 2, 29) is Err(_))
  assert_true(new_date(2026, 4, 31) is Err(_))
  assert_true(new_date(1900, 1, 1) is Err(_))
}

///|
test "Local minute arithmetic crosses month and year boundaries" {
  let start = {
    date: { year: 2026, month: 12, day: 31, },
    hour: 23,
    minute: 59,
  }
  let next = add_minutes(start, 1)
  assert_eq(next.date.year, 2027)
  assert_eq(next.date.month, 1)
  assert_eq(next.date.day, 1)
  assert_eq(next.hour, 0)
  assert_eq(next.minute, 0)
}

///|
fn datetime_after(left : DateTime, right : DateTime) -> Bool {
  if left.date.year != right.date.year {
    return left.date.year > right.date.year
  }
  if left.date.month != right.date.month {
    return left.date.month > right.date.month
  }
  if left.date.day != right.date.day {
    return left.date.day > right.date.day
  }
  if left.hour != right.hour {
    return left.hour > right.hour
  }
  left.minute > right.minute
}

///|
test "next_change always advances and flips the state at its boundary" {
  let expr = match parse("Mo-Fr 09:00-12:00,13:00-18:00") {
    Ok(value) => value
    Err(_) => fail("工作日规则应当可以解析")
  }
  let starts : Array[DateTime] = [
    { date: { year: 2026, month: 11, day: 2, }, hour: 8, minute: 59, },
    { date: { year: 2026, month: 11, day: 2, }, hour: 10, minute: 30, },
    { date: { year: 2026, month: 11, day: 7, }, hour: 13, minute: 0, },
  ]
  for start in starts {
    let state_before = match is_open(expr, start) {
      Ok(value) => value
      Err(_) => fail("测试时间应当有效")
    }
    match next_change(expr, start) {
      Ok(Some(next)) => {
        assert_true(datetime_after(next, start))
        match is_open(expr, add_minutes(next, -1)) {
          Ok(value) => assert_eq(value, state_before)
          Err(_) => fail("边界前一分钟应当有效")
        }
        match is_open(expr, next) {
          Ok(value) => assert_true(value != state_before)
          Err(_) => fail("边界时间应当有效")
        }
      }
      Ok(None) => fail("工作日计划应当发生状态变化")
      Err(_) => fail("有效输入不应返回求值错误")
    }
  }
}
