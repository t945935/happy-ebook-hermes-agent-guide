# 附錄 A：指令速查表

## 啟動與測試

```bash
hermes
hermes --tui
hermes --cli
hermes chat -q "問題"
hermes -z "問題"
hermes --version
hermes doctor
```

## 模型與認證

```bash
hermes setup
hermes model
hermes auth status
hermes auth list
hermes auth add PROVIDER
hermes fallback list
hermes fallback add
```

## 設定與工具

```bash
hermes config show
hermes config get KEY
hermes config check
hermes config path
hermes tools list
hermes tools
```

## Sessions

```bash
hermes --continue
hermes --resume SESSION
hermes sessions list
hermes sessions browse
hermes sessions export OUTPUT
hermes sessions stats
```

## Skills

```bash
hermes skills list
hermes skills search QUERY
hermes skills browse
hermes skills install ID
hermes skills check
hermes skills update
```

## Gateway

```bash
hermes gateway setup
hermes gateway start
hermes gateway status
hermes gateway restart
hermes gateway stop
hermes logs
hermes logs errors
```

## Cron

```bash
hermes cron list
hermes cron status
hermes cron create "every day 9am" "任務"
hermes cron run JOB_ID
hermes cron pause JOB_ID
hermes cron resume JOB_ID
hermes cron remove JOB_ID
```

## MCP、Webhook、Plugin

```bash
hermes mcp catalog
hermes mcp install NAME
hermes mcp list
hermes mcp test NAME
hermes webhook list
hermes webhook test NAME
hermes plugins list
hermes plugins doctor
```

## 介面

```bash
hermes desktop
hermes dashboard
hermes dashboard --status
hermes dashboard --stop
```

詳細選項應以目前安裝版本為準：

```bash
hermes COMMAND --help
```
