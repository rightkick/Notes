# Claude Code Settings

A reference [`settings.json`](settings.json) for [Claude Code](https://docs.claude.com/en/docs/claude-code) covering tool permissions, enabled plugins, marketplace sources, and the default model.

## Where to place the file

Claude Code reads settings from several locations, in order of precedence (most specific wins):

| Path | Scope |
|------|-------|
| `.claude/settings.local.json` | Per-project, not committed (machine-local overrides) |
| `.claude/settings.json` | Per-project, committed to the repo |
| `~/.claude/settings.json` | Per-user, applies to every project |
| `/etc/claude-code/managed-settings.json` | System-wide (managed) |

Drop this file at `~/.claude/settings.json` to use it as your personal default, or copy it into a repo's `.claude/settings.json` to share the policy with collaborators.

```bash
# Personal default
mkdir -p ~/.claude
cp settings.json ~/.claude/settings.json

# Per-project
mkdir -p /path/to/repo/.claude
cp settings.json /path/to/repo/.claude/settings.json
```

## What's inside

### `permissions.allow`
Tool calls that run **without prompting**. Patterns use the form `Bash(<command> *)`, where `*` matches any arguments. Examples included:

- Read-only Git/GitHub inspection (`git log`, `git diff`, `gh pr view`, ...)
- File and text inspection (`cat`, `less`, `grep`, `rg`, `jq`, ...)
- Filesystem navigation (`ls`, `find`, `mkdir`, `pwd`, ...)
- Process and system info (`ps`, `df`, `du`, `uname`, ...)
- Networking diagnostics (`ping`, `dig`, `curl -s`, ...)
- Container and cluster reads (`docker ps`, `docker logs`, `kubectl get`, `kubectl describe`, ...)
- `journalctl` and `systemctl status`

The intent is: anything **observational** is allowed; anything that mutates state should still prompt.

### `permissions.deny`
Tool calls that are **blocked outright**, regardless of confirmation. Categories:

- Destructive filesystem ops (`rm -rf /*`, `mkfs`, `fdisk`, raw `dd` to devices)
- Reverse shells / piped remote-code execution (`curl ... | sh`, `bash -i >& /dev/tcp/*`)
- Account and credential changes (`passwd`, `sudo useradd`, `sudo su`, `pkexec`)
- Dangerous container flags (`--privileged`, `--net=host`, mounting the docker socket)
- Force-pushes and hard resets against `master` / `main`
- Reads of secrets (`~/.aws/*`, `~/.ssh/id_*`)
- Power-state and firewall changes (`shutdown`, `reboot`, `iptables -F`)
- Kernel module and runtime tampering (`insmod`, `LD_PRELOAD=*`, `sysctl -w`)

Deny rules take precedence over allow rules.

### `enabledPlugins`
Plugins are turned on by `"<plugin>@<marketplace>": true`. This config enables:

- `superpowers@claude-plugins-official` — skill bundle (brainstorming, TDD, debugging, plan execution, ...)
- `context7@claude-plugins-official` — up-to-date library/framework docs lookup
- `terraform-skill@antonbabenko` — Terraform/OpenTofu authoring and review skill

### `extraKnownMarketplaces`
Registers third-party plugin marketplaces beyond the official one. Here, the `antonbabenko` marketplace is sourced from the GitHub repo `antonbabenko/terraform-skill`, which is what makes `terraform-skill@antonbabenko` resolvable above.

### `model`
Default model for the session. `opus[1m]` selects Claude Opus with the 1M-token context window. Override per-session with `/model` inside Claude Code.

## Customizing

- **Add a new allow rule:** append a `Bash(<cmd> *)` entry to `permissions.allow`. Be specific — `Bash(rm *)` is far broader than `Bash(rm -i *)`.
- **Tighten a rule:** move it from `allow` to `deny`, or narrow the glob (e.g. `Bash(curl -s https://api.internal.example.com/*)`).
- **Disable a plugin:** flip its value to `false` in `enabledPlugins` (keeps it installed but inactive).
- **Switch models:** change `"model"` to `sonnet`, `haiku`, `opus`, or a versioned ID like `claude-opus-4-7`.

After editing, restart Claude Code or run `/config reload` to pick up the changes.

## Verifying

```bash
# Validate JSON syntax
jq . ~/.claude/settings.json

# Inside Claude Code, view the merged effective settings
/config
```

## References

- Settings reference: <https://docs.claude.com/en/docs/claude-code/settings>
- Permissions: <https://docs.claude.com/en/docs/claude-code/iam>
- Plugins & marketplaces: <https://docs.claude.com/en/docs/claude-code/plugins>
