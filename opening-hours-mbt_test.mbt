///|
test "解析工作日和多段时段" {
  match @opening-hours-mbt.parse("Mo-Fr 09:00-12:00,13:00-18:00") {
    Ok(expr) => {
      assert_eq(expr.rules.length(), 1)
      assert_eq(expr.rules[0].weekdays, [0, 1, 2, 3, 4])
      assert_eq(expr.rules[0].times.length(), 2)
      assert_eq(expr.rules[0].times[0].start_minute, 540)
      assert_eq(expr.rules[0].times[0].end_minute, 720)
      assert_eq(expr.rules[0].times[1].start_minute, 780)
      assert_eq(expr.rules[0].times[1].end_minute, 1080)
    }
    Err(_) => fail("工作日时段应该可以解析")
  }
}

///|
test "解析单日集合和跨周星期范围" {
  match @opening-hours-mbt.parse("Mo,We,Fr 10:00-12:00; Fr-Mo 14:00-16:00") {
    Ok(expr) => {
      assert_eq(expr.rules.length(), 2)
      assert_eq(expr.rules[0].weekdays, [0, 2, 4])
      assert_eq(expr.rules[1].weekdays, [4, 5, 6, 0])
    }
    Err(_) => fail("星期集合和跨周范围应该可以解析")
  }
}

///|
test "解析全天与关闭关键字" {
  match @opening-hours-mbt.parse("24/7; Sa off; Su closed") {
    Ok(expr) => {
      assert_eq(expr.rules.length(), 3)
      assert_eq(expr.rules[0].times[0].start_minute, 0)
      assert_eq(expr.rules[0].times[0].end_minute, 1440)
      assert_true(expr.rules[1].state is @opening-hours-mbt.RuleState::Closed)
      assert_eq(expr.rules[1].times.length(), 0)
      assert_true(expr.rules[2].state is @opening-hours-mbt.RuleState::Closed)
    }
    Err(_) => fail("24/7、off 和 closed 应该可以解析")
  }
}

///|
test "拒绝空规则并指出末尾位置" {
  match @opening-hours-mbt.parse("Mo-Fr 09:00-18:00;") {
    Err(error) => {
      assert_eq(error.position, 18)
      assert_eq(error.message, "规则不能为空")
    }
    Ok(_) => fail("末尾分号后缺少规则")
  }
}

///|
test "拒绝非法时间并指出时间起点" {
  match @opening-hours-mbt.parse("Mo-Fr 25:00-26:00") {
    Err(error) => {
      assert_eq(error.position, 6)
      assert_eq(error.message, "时间超出允许范围")
    }
    Ok(_) => fail("小时不能超过 24")
  }
}

///|
test "拒绝无效星期缩写并指出字符位置" {
  match @opening-hours-mbt.parse("Mo-XX 09:00-18:00") {
    Err(error) => {
      assert_eq(error.position, 3)
      assert_eq(error.message, "未知星期缩写")
    }
    Ok(_) => fail("无效星期缩写必须报错")
  }
}

///|
test "拒绝不支持的变量时间" {
  match @opening-hours-mbt.parse("Mo-Fr sunrise-sunset") {
    Err(error) => {
      assert_eq(error.position, 6)
      assert_eq(error.message, "规则中存在无法识别的词")
    }
    Ok(_) => fail("变量时间不属于支持范围")
  }
}

///|
test "拒绝非法的全天关键字" {
  match @opening-hours-mbt.parse("24/8") {
    Err(error) => {
      assert_eq(error.position, 0)
      assert_eq(error.message, "不支持或无法识别的规则选择器")
    }
    Ok(_) => fail("只能使用 24/7 表示全天营业")
  }
}

///|
test "拒绝非规范时间格式和越界分钟" {
  match @opening-hours-mbt.parse("Mo-Fr 9:00-18:00") {
    Err(error) => assert_eq(error.position, 6)
    Ok(_) => fail("小时必须有两位数字")
  }
  match @opening-hours-mbt.parse("Mo-Fr 09:60-18:00") {
    Err(error) => assert_eq(error.position, 6)
    Ok(_) => fail("分钟不能超过 59")
  }
}

///|
fn parsed(value : String) -> @opening-hours-mbt.Expr? {
  match @opening-hours-mbt.parse(value) {
    Ok(expr) => Some(expr)
    Err(_) => None
  }
}

///|
fn at(
  year : Int32,
  month : Int32,
  day : Int32,
  hour : Int32,
  minute : Int32,
) -> @opening-hours-mbt.DateTime {
  { date: { year, month, day, }, hour, minute, }
}

///|
fn open_result(
  expr : @opening-hours-mbt.Expr,
  datetime : @opening-hours-mbt.DateTime,
) -> Bool? {
  match @opening-hours-mbt.is_open(expr, datetime) {
    Ok(actual) => Some(actual)
    Err(_) => None
  }
}

///|
test "后续普通规则替换同一天的营业时段" {
  match parsed("Mo-Fr 09:00-18:00; We 12:00-14:00") {
    Some(expr) => {
      assert_eq(open_result(expr, at(2026, 11, 4, 10, 0)), Some(false))
      assert_eq(open_result(expr, at(2026, 11, 4, 12, 0)), Some(true))
      assert_eq(open_result(expr, at(2026, 11, 4, 14, 0)), Some(false))
      assert_eq(open_result(expr, at(2026, 11, 2, 10, 0)), Some(true))
    }
    None => fail("工作日规则应当可以解析")
  }
}

///|
test "off 规则从既有时段中扣除匹配窗口" {
  match parsed("Mo-Fr 09:00-18:00; We 12:00-14:00 off") {
    Some(expr) => {
      assert_eq(open_result(expr, at(2026, 11, 4, 11, 59)), Some(true))
      assert_eq(open_result(expr, at(2026, 11, 4, 12, 0)), Some(false))
      assert_eq(open_result(expr, at(2026, 11, 4, 14, 0)), Some(true))
    }
    None => fail("关闭时段应当可以解析")
  }
}

///|
test "跨午夜窗口营业到结束时刻但不含结束边界" {
  match parsed("Sa 22:00-02:00") {
    Some(expr) => {
      assert_eq(open_result(expr, at(2026, 11, 7, 21, 59)), Some(false))
      assert_eq(open_result(expr, at(2026, 11, 7, 22, 0)), Some(true))
      assert_eq(open_result(expr, at(2026, 11, 8, 0, 30)), Some(true))
      assert_eq(open_result(expr, at(2026, 11, 8, 2, 0)), Some(false))
    }
    None => fail("跨午夜规则应当可以解析")
  }
}

///|
test "次日普通规则会覆盖前一日的跨午夜尾段" {
  match parsed("Sa 16:00-03:00; Su 16:00-23:00") {
    Some(expr) => {
      assert_eq(open_result(expr, at(2026, 11, 8, 1, 0)), Some(false))
      assert_eq(open_result(expr, at(2026, 11, 8, 16, 0)), Some(true))
    }
    None => fail("周日规则应当可以解析")
  }
}

///|
test "按日营业时间段保留午休并裁剪跨日窗口" {
  match parsed("Mo-Fr 09:00-12:00,13:00-18:00; Sa 22:00-02:00") {
    Some(expr) => {
      let monday : @opening-hours-mbt.Date = { year: 2026, month: 11, day: 2, }
      match @opening-hours-mbt.opening_periods_for_day(expr, monday) {
        Ok(periods) => {
          assert_eq(periods.length(), 2)
          assert_eq(periods[0].start_minute, 540)
          assert_eq(periods[0].end_minute, 720)
          assert_eq(periods[1].start_minute, 780)
          assert_eq(periods[1].end_minute, 1080)
        }
        Err(_) => fail("应当返回星期一的营业时间段")
      }
    }
    None => fail("每日营业规则应当可以解析")
  }
}

///|
test "周营业时间表包含七天和周末跨午夜尾段" {
  match parsed("Mo-Fr 09:00-18:00; Sa 22:00-02:00") {
    Some(expr) => {
      let monday : @opening-hours-mbt.Date = { year: 2026, month: 11, day: 2, }
      match @opening-hours-mbt.opening_periods_for_week(expr, monday) {
        Ok(schedules) => {
          assert_eq(schedules.length(), 7)
          assert_eq(schedules[6].date.day, 8)
          assert_eq(schedules[6].periods.length(), 1)
          assert_eq(schedules[6].periods[0].start_minute, 0)
          assert_eq(schedules[6].periods[0].end_minute, 120)
        }
        Err(_) => fail("应当返回完整的一周")
      }
    }
    None => fail("周营业规则应当可以解析")
  }
}

///|
test "日历时间表拒绝非星期一的周起点" {
  match parsed("24/7") {
    Some(expr) => {
      let tuesday : @opening-hours-mbt.Date = { year: 2026, month: 11, day: 3, }
      assert_true(
        @opening-hours-mbt.opening_periods_for_week(expr, tuesday) is Err(_),
      )
    }
    None => fail("24/7 应当可以解析")
  }
}

///|
test "next_change 返回下一个严格晚于输入的状态边界" {
  match parsed("Mo-Fr 09:00-12:00,13:00-18:00") {
    Some(expr) => {
      match @opening-hours-mbt.next_change(expr, at(2026, 11, 2, 8, 59)) {
        Ok(Some(next)) => {
          assert_eq(next.date.day, 2)
          assert_eq(next.hour, 9)
          assert_eq(next.minute, 0)
        }
        _ => fail("应当找到星期一的开门时刻")
      }
      match @opening-hours-mbt.next_change(expr, at(2026, 11, 2, 17, 59)) {
        Ok(Some(next)) => {
          assert_eq(next.hour, 18)
          assert_eq(next.minute, 0)
        }
        _ => fail("应当找到星期一的关门时刻")
      }
    }
    None => fail("工作日规则应当可以解析")
  }
}

///|
test "稳定全天营业或全天关闭没有下一次状态变化" {
  match parsed("24/7") {
    Some(expr) =>
      assert_true(
        @opening-hours-mbt.next_change(expr, at(2026, 11, 2, 10, 0)) is Ok(None),
      )
    None => fail("24/7 应当可以解析")
  }
  match parsed("off") {
    Some(expr) =>
      assert_true(
        @opening-hours-mbt.next_change(expr, at(2026, 11, 2, 10, 0)) is Ok(None),
      )
    None => fail("off 应当可以解析")
  }
}

///|
test "不合法的本地日期时间返回求值错误" {
  match parsed("24/7") {
    Some(expr) => {
      let invalid : @opening-hours-mbt.DateTime = {
        date: { year: 2026, month: 11, day: 2, },
        hour: 24,
        minute: 0,
      }
      assert_true(@opening-hours-mbt.is_open(expr, invalid) is Err(_))
      assert_true(@opening-hours-mbt.next_change(expr, invalid) is Err(_))
    }
    None => fail("24/7 应当可以解析")
  }
}
