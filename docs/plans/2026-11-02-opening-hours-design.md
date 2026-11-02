# opening-hours.mbt 设计说明 / Design Notes

## 目标

构建一个原创的 MoonBit 库，用于解析和求值 OpenStreetMap `opening_hours` 子集。第一阶段聚焦可在营业时间查询、下一次状态变化与日期区间列表；所有时间由调用方传入，采用表达式所在地区的本地民用时间，不偷偷读取系统时区。

## 架构

核心包采用纯函数和显式数据结构：`Date`、`DateTime`、`Rule`、`TimeRange`、`HolidayCalendar`、`ParseError`。解析器以字符扫描器产生带起止偏移的错误，AST 只保存语法意义，不依赖外部实现。求值器先筛选日期与节假日规则，再按 OSM 的规则顺序处理时段；以日期为单位应用普通分号规则，以逗号时段并集合并同一规则中的窗口，`off/closed` 对匹配窗口执行关闭。跨午夜时段归属于开始日期，并在次日规则存在时按规范处理覆盖。

`next_change` 返回 `Option[DateTime]`，对有界查找范围内的逐分钟状态边界做确定性搜索；没有可观察状态变化时返回 `None`。非法输入通过 `Result` 返回位置化诊断。日期区间查询复用同一 evaluator，避免 API 之间出现不同语义。

## 组件与交付

- `src/`：解析、AST、日期运算、节假日日历、求值与 API。
- `cmd/`：命令行入口。
- `web/`：编译后的 JS/Wasm 演示入口与静态页面。
- `tests/fixtures/`：由 OSM Wiki 示例整理的至少 50 条回归表达式及来源。
- `.github/workflows/ci.yml`：`moon check`、`moon test`、`moon fmt`。

周计划分阶段合并，但所有开发提交均使用项目作者 `wccerty`；不生成 Co-authored-by。中国节假日数据按年份与来源单独存档，明确它只是示例日历，调用方可传自己的 PH/SH 数据。

## 规范与限制

参考 [OSM opening_hours specification](https://wiki.openstreetmap.org/wiki/Key:opening_hours/specification) 0.7.4。项目范围覆盖星期、月份/日期、多个时段、24/7、off/closed、跨午夜与注入式 PH/SH。日出日落、自然语言注释、周序号及更复杂扩展暂不实现；遇到不支持语法返回位置化错误，不做猜测式解析。