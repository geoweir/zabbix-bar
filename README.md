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

## Install Locally

```bash
mkdir -p ~/.config/omarchy/plugins/local.zabbix-problems
cp -a manifest.json BarWidget.qml zabbix-counts README.md ~/.config/omarchy/plugins/local.zabbix-problems/
chmod +x ~/.config/omarchy/plugins/local.zabbix-problems/zabbix-counts
omarchy-shell shell rescanPlugins
omarchy plugin enable local.zabbix-problems --section right
```

Left-click the widget to open the detail popup. Right-click it to refresh
immediately. The popup also includes refresh and browser buttons.
