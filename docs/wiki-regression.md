# OSM Wiki 回归样例

`tests/fixtures/osm-wiki-examples.tsv` 汇集了 60 条来自 OpenStreetMap Wiki `Key:opening_hours` 页面「Explanation by example」「Values / Examples」及「Comment」部分的表达式。测试断言位于 [`wiki_examples_test.mbt`](../wiki_examples_test.mbt)，运行 `moon test`。

## 来源与版本

- 来源页：[Key:opening_hours 固定版本](https://wiki.openstreetmap.org/w/index.php?title=Key%3Aopening_hours&oldid=3110538)，页面修订号 `3110538`；该版本页脚标注的最后编辑时间为 2026-10-31 16:40。
- 样例整理日期：2026-11-02。该固定版本与整理时页面一致。
- 页面历史：[Key:opening_hours 历史记录](https://wiki.openstreetmap.org/w/index.php?title=Key%3Aopening_hours&action=history)。OpenStreetMap Wiki 的内容许可页说明，Wiki 文本采用 CC BY-SA 2.0（页面另有声明时除外），并可从各页历史记录查阅文本作者：[Wiki 内容许可](https://wiki.openstreetmap.org/wiki/Wiki_content_license)。

回归样例集按来源单独注明 CC BY-SA 2.0 和上述归属信息。仓库根目录的 Apache-2.0 许可用于项目原创代码；使用或再分发回归样例时，请同时保留本来源说明及 Wiki 许可信息。此处的样例来源是 Wiki 文本，不是从 OSM 地理数据库导出的地图数据。

## 分类与处理

`accept` 表示表达式属于本项目当前实现的语法子集；`reject` 表示 Wiki 中的真实表达式使用了本项目暂未支持的语法（例如太阳事件、周编号、Easter、additional/fallback 规则、注释或年份）。拒绝样例用于验证解析器返回错误而不崩溃，并不表示表达式违反 OSM 规范。

Wiki 页面中的部分内联代码在页面抽取文本时被拆分了空格；TSV 中按规范词法形式恢复空格和标点（例如时间列表的逗号后不加空格）。表达式均来自 Wiki 示例，没有添加合成表达式。
