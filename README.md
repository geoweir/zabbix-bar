# Zabbix Problems for Omarchy

Omarchy bar widget showing **Zabbix Problems** counts as:

```text
disaster/high/average/warning
```

It intentionally ignores `information` and `not classified`, disabled hosts,
disabled triggers, and dependent triggers. Internally it uses `trigger.get`
for active monitored triggers that are firing now, because `problem.get` can
return old unresolved event rows that are hidden from the Zabbix Problems UI.

## Configure

Create `~/.config/omarchy/zabbix-bar.env`:

```bash
ZABBIX_URL="https://zabbix.example.com/zabbix"
ZABBIX_API_TOKEN="paste-token-here"
```

`ZABBIX_URL` may be either the frontend URL or the full
`api_jsonrpc.php` URL.

Optional settings:

```bash
ZABBIX_TIMEOUT_SECONDS=8
```

## Install

```bash
omarchy plugin add https://github.com/geoweir/zabbix-bar.git --enable
```

This clones the repo into `~/.config/omarchy/plugins/geoweir.zabbix-problems`
and enables the widget on the bar. Then create the config file above.

Update later with:

```bash
omarchy plugin update geoweir.zabbix-problems
```

Plugins run unsandboxed inside the shell, so review the code before enabling.

Left-click the widget to open the detail popup. Right-click it to refresh
immediately. The popup also includes refresh and browser buttons.
