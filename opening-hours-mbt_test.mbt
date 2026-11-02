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
