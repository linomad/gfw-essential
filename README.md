# 经纬域谱

分层维护高价值与低价值域名规则，稳定产出可被主流代理软件直接消费的统一规则文件。

## 分层结构

- 源数据层：`sources/high_*.txt` 与 `sources/low_*.txt`
- 参考输入：`reference/gfw.txt`
- 构建产物：`dist/high_unified.txt`

`dist/high_unified.txt` 由全部 `sources/high_*.txt` 合并生成，并自动去空行、排序、去重。

## 常用命令

- 生成产物：`make build`
- 校验产物是否最新：`make check`
- 运行测试：`make test`

## 通用代理软件用法

将 `dist/high_unified.txt` 作为高优先级域名规则源，可用于 Surge、Clash、sing-box、Quantumult X 等支持远程或本地规则列表的代理软件。
