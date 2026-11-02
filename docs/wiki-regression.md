# OSM Wiki 回归样例

`tests/fixtures/osm-wiki-examples.tsv` 汇集了 60 条来自 OpenStreetMap Wiki `Key:opening_hours` 页面「Explanation by example」「Values / Examples」及「Comment」示例的表达式。来源页面：[Key:opening_hours](https://wiki.openstreetmap.org/wiki/Key:opening_hours)。

回归测试会对每一条表达式断言当前解析器是否接受。`accept` 表示表达式属于本项目当前实现的语法子集；`reject` 表示 Wiki 中的真实表达式使用了本项目范围外语法（例如太阳事件、周编号、Easter、nth weekday、additional/fallback 规则、注释或年份）。这些拒绝样例用于确保错误返回而不是崩溃，并不表示表达式违反 OSM 规范。

Wiki 页面中的部分内联代码在页面抽取文本时被拆分了空格；fixture 按 OSM 规范的词法形式恢复了空格和标点（例如时间列表中的逗号后不加空格）。表达式本身来自 Wiki 示例，不添加合成示例。

测试入口：`wiki_examples_test.mbt`。运行 `moon test`。
