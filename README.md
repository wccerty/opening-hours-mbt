# opening-hours-mbt

用 MoonBit 编写的 OpenStreetMap `opening_hours` 表达式解析与求值库，可判断指定本地时间是否营业、查询下次状态变化，并列出一天或一周的营业时段。

> A MoonBit parser and evaluator for the OpenStreetMap `opening_hours` syntax.

## 安装 MoonBit

Windows PowerShell：

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```

Linux / macOS：

```bash
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
```

## 获取源码

```bash
git clone https://github.com/wccerty/opening-hours-mbt.git
cd opening-hours-mbt
moon check
moon test
```

截至 2026-11-03，`moon search "wccerty/opening-hours-mbt"` 未找到已发布的包版本。当前请通过源码克隆和本地工作区引用使用；发布到 MoonBit 包索引后会在此补充注册表安装命令。

在另一个 MoonBit 模块中本地引用时，把此仓库和应用放在同一个 `moon.work` 工作区：

```toml
# moon.work
members = ["my-app", "opening-hours-mbt"]
```

应用的 `moon.mod` 声明模块依赖：

```toml
import {
  "wccerty/opening-hours-mbt@0.1.0",
}
```

应用包的 `moon.pkg` 导入根包：

```toml
import {
  "wccerty/opening-hours-mbt",
}
```

## API 示例

```moonbit
let expr = match @opening-hours-mbt.parse(
  "Mo-Fr 09:00-12:00,13:00-18:00; Sa 10:00-14:00; PH off",
) {
  Ok(value) => value
  Err(error) => fail("表达式错误（位置 \{error.position}）：\{error.message}")
}
let local_time : @opening-hours-mbt.DateTime = {
  date: { year: 2026, month: 11, day: 2, },
  hour: 10,
  minute: 30,
}
let open_now = @opening-hours-mbt.is_open(expr, local_time)
let transition = @opening-hours-mbt.next_change(expr, local_time)
```

`is_open`、`next_change` 和营业时段查询接受本地日历时间，不自动转换时区。`next_change` 返回严格晚于输入时刻的第一个状态变化，搜索窗口为 370 天；在窗口内找不到变化时返回 `None`。日期构造器会验证公历日期和时间。

对 `PH` / `SH` 规则，可传入自己的日历：

```moonbit
let calendar : @opening-hours-mbt.HolidayCalendar = {
  public_holidays: [{ year: 2026, month: 10, day: 1, }],
  school_holidays: [],
}
let open_on_holiday = @opening-hours-mbt.is_open_with_calendar(
  expr,
  local_time,
  calendar,
)
```

## CLI

```bash
moon run cmd/cli --target native "Mo-Fr 09:00-18:00" 2026-11-02T10:30
```

时间参数格式为 `YYYY-MM-DDTHH:MM`，代表本地墙上时间。CLI 输出营业状态和下次状态变化；解析失败时会显示从 0 开始的错误位置。

## 网页演示

构建 MoonBit 的 Wasm 和 JavaScript 版本，并准备静态网页：

```powershell
./scripts/build-web.ps1
python -m http.server 8080 --directory web/demo
```

打开 `http://localhost:8080`。网页在浏览器中完成计算，可以选择注入中国 2026 年放假日历。推送到 `main` 后，GitHub Actions 会运行检查并发布 GitHub Pages 演示页：<https://wccerty.github.io/opening-hours-mbt/>。

假期数据的来源和 `PH` 示例口径见 [`docs/holidays.md`](docs/holidays.md)。

## 支持范围

| 语法 | 当前支持情况 |
| --- | --- |
| 星期集合与范围，如 `Mo,We`、`Mo-Fr`、`Fr-Mo` | 支持 |
| 月内第 N 个星期几，如 `Mo[2]`、`Mo[-1]` | 支持单个序号 `1` 至 `5`、`-1` 至 `-5`；不支持序号列表或范围 |
| 一天多个时间段，如 `09:00-12:00,13:00-18:00` | 支持 |
| 分号规则与顺序覆盖 | 支持 |
| `24/7`、`off`、`closed` | 支持 |
| 跨午夜，如 `22:00-02:00` / `22:00-26:00` | 支持 |
| 月份集合与范围，如 `Jan,Mar`、`Jan-Mar` | 支持 |
| 月日与跨年日期范围，如 `Dec 24-26`、`Dec 24-Jan 3` | 支持 |
| `PH`、`SH` | 支持；由调用者注入明确日期 |
| 日出日落等变量时间、周编号、Easter 与节日偏移 | 暂不支持 |
| additional / fallback 规则、注释和开放结束时间 | 暂不支持 |

无法识别的语法返回带位置的 `ParseError`。完整范围和后续工作见 [`docs/plans/2026-11-02-opening-hours-plan.md`](docs/plans/2026-11-02-opening-hours-plan.md)。

## 测试

当前 `moon test` 包含 35 条测试，全部通过；其中包含 60 条 OSM Wiki 表达式解析断言（29 条应由当前子集接受，31 条应返回不支持语法错误）。样例来源和分类见 [`docs/wiki-regression.md`](docs/wiki-regression.md) 与 [`tests/fixtures/osm-wiki-examples.tsv`](tests/fixtures/osm-wiki-examples.tsv)。OSM Wiki 样例集有独立的来源与许可说明；仓库根目录 Apache-2.0 许可不替代该样例集的来源标注，详见回归样例文档。

本地完整检查：

```bash
moon fmt --check
moon check --deny-warn
moon test
moon build cmd/cli --target native --release
moon build web/bridge --target wasm --release
moon build web/bridge --target js --release
```

GitHub Actions 在每次推送和 Pull Request 上运行格式检查、类型检查、测试及三个构建目标。

## 使用场景

1. **门店“营业中”标识**：按当前本地时间刷新营业状态，并展示下次开门或关门时刻。
2. **外卖平台下单时间校验**：下单前判断门店是否营业，避免在关闭时段创建订单。
3. **地图 POI 数据清洗**：批量验证 OSM 营业时间字段，对不支持或非法的表达式记录位置化错误。

## 许可

Apache-2.0，见 [`LICENSE`](LICENSE)。
