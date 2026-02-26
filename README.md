# gfw-essential

从全量 GFW 列表中过滤并提取主流域名，按优先级分层维护，产出可被代理软件直接消费的规则集。

项目当前优先保障主流 AI 服务的可用性与完整性，因此 AI 相关域名独立维护在强烈推荐层。

## 分层结构

源数据文件统一命名为：`sources/<level>_<category>.txt`

- `must`（必选）：通用基础平台，默认必须纳入（例如 Google 相关）
- `strong`（强烈推荐）：高频核心服务，默认纳入（例如 AI、社区）
- `optional`（可选）：按用户诉求选择纳入（例如 crypto、adult、engineering、vpn）
- `avoid`（不建议）：冷门或长尾集合，默认不纳入
- 参考输入：`reference/gfw.txt`
- 构建产物：`dist/final_valuable_domains.txt`

默认构建使用以下分类：`platforms,engineering,ai,community,content,services`，合并后会自动去空行、排序、去重。
构建支持两种选择器，且二选一：

- 按级别：`--levels must,strong,optional`
- 按类别：`--categories ai,community`

## 分类意图与维护原则

- 分层用于表达推荐强度，而非替代类别。
- 类别后缀保持稳定（如 `*_ai.txt`、`*_crypto.txt`），通过前缀控制级别。
- 同一域名不应跨级重复，避免维护歧义。
- AI 关键链路优先放在 `strong_ai.txt`，覆盖 ChatGPT/OpenAI/Gemini/Grok/Claude/Copilot/Perplexity/Poe/HuggingFace 等主流服务。
- `reference/gfw.txt` 作为基础参考源，必要时可补充关键链路域名。

## 常用命令

- 生成默认产物（默认 categories）：`make build`
- 校验默认产物是否最新：`make check`
- 生成自定义级别组合：`make build LEVELS=must,strong,optional`
- 校验自定义级别组合：`make check LEVELS=must,strong,optional`
- 按类别生成：`make build CATEGORIES=ai,community`
- 按类别校验：`make check CATEGORIES=ai,community`
- 运行测试：`make test`

也可直接调用脚本：

- `./scripts/build_high_unified.sh`（使用默认 categories）
- `./scripts/build_high_unified.sh --check`（校验默认 categories）
- `./scripts/build_high_unified.sh --levels must,strong`
- `./scripts/build_high_unified.sh --levels all`
- `./scripts/build_high_unified.sh --check --levels must,strong,optional`
- `./scripts/build_high_unified.sh --categories ai,community`
- `./scripts/build_high_unified.sh --check --categories ai,community`

## 通用代理软件用法

将 `dist/final_valuable_domains.txt` 作为高优先级域名规则源，可用于 Surge、Clash、sing-box、Quantumult X 等支持远程或本地规则列表的代理软件。
