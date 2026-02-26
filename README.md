# gfw-essential

从全量 GFW 列表中过滤并提取高频主流域名，产出可被代理软件直接消费的核心高优规则集。

项目当前的第一目标是保证主流 AI 服务可用性与完整性，因此将 AI 相关域名独立维护为高优分类。

## 分层结构

- 高优源：`sources/high_*.txt`（参与构建，进入最终产物）
- 低优源：`sources/low_*.txt`（长尾候选，不直接进入最终产物）
- AI 专属高优分类：`sources/high_ai.txt`
- 参考输入：`reference/gfw.txt`
- 构建产物：`dist/final_valuable_domains.txt`

`dist/final_valuable_domains.txt` 由全部 `sources/high_*.txt` 合并生成，并自动去空行、排序、去重。

## 分类意图与维护原则

- 高优集合用于“默认应保证可访问”的核心服务域名。
- `high_ai` 用于集中维护 AI 服务关键域名，优先覆盖 ChatGPT/OpenAI/Gemini/Grok/Claude/Copilot/Perplexity/Poe/HuggingFace 等主流服务链路。
- 分类应保持互斥：同一域名不应同时存在于 `high_*.txt` 与 `low_*.txt`。
- 当 AI 域名被提升为高优后，应从对应 `low_*` 文件中移除，避免语义冲突和维护歧义。
- `reference/gfw.txt` 作为基础参考源，必要时可为关键 AI 链路补充高优域名。

## 常用命令

- 生成产物：`make build`
- 校验产物是否最新：`make check`
- 运行测试：`make test`

## 通用代理软件用法

将 `dist/final_valuable_domains.txt` 作为高优先级域名规则源，可用于 Surge、Clash、sing-box、Quantumult X 等支持远程或本地规则列表的代理软件。
