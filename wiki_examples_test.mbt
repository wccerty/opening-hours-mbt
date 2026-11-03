///|
test "OSM Wiki 样例按支持子集解析" {
  let mut count = 0
  assert_true(@opening-hours-mbt.parse("Mo-Fr 08:00-17:00") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 08:00-12:00,13:00-17:30") is Ok(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo,We 08:00-12:00") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00")
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00; PH off",
    )
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00; PH off; SH off",
    )
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00; PH 09:00-12:00",
    )
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00; SH Mo-Sa 09:00-12:00",
    )
    is Ok(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo 20:00-26:00") is Ok(_))
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo 20:00-02:00") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo 20:00-24:00; Tu 00:00-02:00") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo 20:00-26:00; Tu 20:00-24:00") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo 08:00-16:00; Mo[2] 08:00-12:00") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo 08:00-16:00; Mo[-2] 08:00-12:00") is Ok(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo 08:00-16:00; Dec off") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 08:00-16:00; Dec 12 off") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo 08:00-16:00; Dec Mo 08:00-12:00") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo 08:00-16:00; Jan-Mar Mo 08:00-12:00") is Ok(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("24/7") is Ok(_))
  count += 1
  assert_true(@opening-hours-mbt.parse("Sa-Su 00:00-24:00") is Ok(_))
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo-Fr 08:30-20:00") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo 10:00-12:00,12:30-15:00; Tu-Fr 08:00-12:00,12:30-15:00; Sa 08:00-12:00",
    )
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Su 08:00-18:00; Apr 10-15 off; Jun 08:00-14:00; Aug off; Dec 25 off",
    )
    is Ok(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo-Sa 10:00-20:00; Tu off") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Sa 10:00-20:00; Tu 10:00-14:00") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Tu-Fr 10:00-16:00, Mo 08:00-18:00 open \"limited service\", Tu-Fr 08:00-10:00 open \"limited service\", Tu-Fr 16:00-18:00 open \"limited service\"",
    )
    is Err(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("sunrise-sunset") is Err(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("(sunrise+02:00)-(sunset-02:00)") is Err(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("dawn-dusk") is Err(_))
  count += 1
  assert_true(@opening-hours-mbt.parse("dawn-sunrise, sunset-dusk") is Err(_))
  count += 1
  assert_true(@opening-hours-mbt.parse("Su 10:00+") is Err(_))
  count += 1
  assert_true(@opening-hours-mbt.parse("Apr-Oct: Fr-Su 10:00-18:00") is Ok(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse("May Mo[-1] -2 days-Sep Mo[1]: Sa-Su 10:00-18:00")
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("week 01-14 Mo-Su 10:00-17:00") is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "week 01-53/2 Fr 09:00-12:00; week 02-52/2 We 09:00-12:00",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "10:30-19:00; Jan 01-31/2,Feb 01-29/2,Mar 01-31/2,Apr 01-30/2,May 01-31/2,Jun 01-30/2,Jul 01-31/2,Aug 01-31/2,Sep 01-30/2,Oct 01-31/2,Nov 01-30/2,Dec 01-31/2 07:30-13:30; Su 10:00-13:00; Sa off",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Sa 08:00-13:00,14:00-17:00 || \"by appointment\"",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Su-Tu 11:00-01:00, We-Th 11:00-03:00, Fr 11:00-06:00, Sa 11:00-07:00",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo 11:00-14:00; Tu-Fr 11:00-14:00, 18:00-22:00; Sa 18:00-22:00",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 11:00-14:00, Tu-Sa 18:00-22:00") is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Th 18:00-01:00, Fr-Sa 18:00-03:00") is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo 18:00-24:00; Tu-Fr 00:00-01:00,18:00-24:00; Sa 00:00-03:00,18:00-24:00; Su 00:00-03:00",
    )
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 08:00-12:00, We 14:00-18:00") is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 08:00-12:00; We 08:00-12:00,14:00-18:00")
    is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Su,PH 15:00-03:00; easter -2 days off")
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "easter-7days - Nov 01: Tu-Sa 10:00-12:00,13:30-17:00; easter-7days - Nov 01: Su,PH 11:00-17:00",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Dec 11-Dec 17: Su 10:00-17:00") is Ok(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Fr 09:00-12:30,13:30-17:00; PH -1 day 09:00-12:30; Sa-Su,PH off",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Tu-Sa 09:00-17:00; PH-2days Sa off; PH-1day Sa off; PH off",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Jan 20, Feb 20, Mar 20, Apr 20, May 20, Jun 20, Jul 20, Aug 20, Sep 20, Oct 20, Nov 20, Dec 20 09:00-10:00",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse("Mo-Fr 12:00-14:00 \"winter\"") is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Sa open, Mo-Fr 17:00+ closed, Sa 12:00+ closed; Su,PH off",
    )
    is Err(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("2026 Dec 01-2026 Dec 23") is Err(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "closed; 2026 Nov 01-2026 Dec 31: Mo-Fr 09:00-17:00",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Fr 08:00-09:00 open \"only service\", Mo-Fr 09:00-16:00 open \"service and sales\"",
    )
    is Err(_),
  )
  count += 1
  assert_true(@opening-hours-mbt.parse("Mo-Sa \"on appointment\"") is Err(_))
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo 12:00-14:00 open \"female only\", Mo 14:00-16:00 open \"male only\"",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Sa 08:00-13:00,14:00-17:00 || \"on appointment\"",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Tu 17:00-19:30 \"days on schedule (see website)\"",
    )
    is Err(_),
  )
  count += 1
  assert_true(
    @opening-hours-mbt.parse(
      "Mo-Sa 08:00-13:00,14:00-17:00 || \"on appointment\"; PH off",
    )
    is Err(_),
  )
  count += 1
  assert_eq(count, 60)
}
