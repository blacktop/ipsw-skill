# ipsw-skill

An AI agent skill for Apple firmware and binary reverse engineering using the [ipsw](https://github.com/blacktop/ipsw) CLI tool.

Supports **Claude Code**, **Codex CLI**, **Antigravity**, **Gemini CLI**, and **Pi (pi-coding-agent)**.

## What This Skill Provides

This skill empowers AI agents to assist with:

- **Remote-first firmware triage** - inspect IPSWs/OTAs and pull single components without downloading the whole image
- **Firmware components** - kernelcaches, dyld_shared_cache, exclave/SEP/SPTM/coprocessor firmware, IMG4, AEA, OTA payloads
- **Userspace reverse engineering** - DSC symbol lookup, disassembly, xrefs, imports, soft links
- **ObjC/Swift headers** - dump private framework interfaces and diff them between releases
- **Kernel & KEXT analysis** - symbolication, C++ classes, syscalls/MIG, KEXT extraction
- **Sandbox and entitlements** - decompile profiles, capability queries, entitlement search
- **Release diffing and crash symbolication** - patch hunting between builds, panics and crash logs

## Installation

### Prerequisites

Install the `ipsw` CLI tool:

```bash
brew install blacktop/tap/ipsw
```

Pick one install method per agent. Installing both a plugin and a standalone copy loads the skill
twice (`ipsw` and `ipsw:ipsw`).

### skills.sh

```bash
npx skills add https://github.com/blacktop/ipsw-skill --skill ipsw
```

### Claude Code

Install from the marketplace:

```bash
claude plugin marketplace add blacktop/ipsw-skill
claude plugin install ipsw@ipsw-skill
```

Or install manually:

```bash
git clone https://github.com/blacktop/ipsw-skill /tmp/ipsw-skill

# User-wide (available in all projects)
mv /tmp/ipsw-skill/ipsw ~/.claude/skills/ipsw

# Project-specific (check into your repo)
mv /tmp/ipsw-skill/ipsw .claude/skills/ipsw
```

### Codex CLI

Install from the marketplace:

```bash
codex plugin marketplace add blacktop/ipsw-skill
codex plugin add ipsw@ipsw-skill
```

Or use the built-in skill installer:

```bash
$skill-installer https://github.com/blacktop/ipsw-skill --path ipsw
```

Or install manually:

```bash
git clone https://github.com/blacktop/ipsw-skill /tmp/ipsw-skill

# User-wide
mv /tmp/ipsw-skill/ipsw ~/.codex/skills/ipsw

# Project-specific
mv /tmp/ipsw-skill/ipsw .codex/skills/ipsw
```

### Antigravity

Install the skill manually:

```bash
git clone https://github.com/blacktop/ipsw-skill /tmp/ipsw-skill

# Workspace-specific
mv /tmp/ipsw-skill/ipsw <workspace-root>/.agents/skills/ipsw

# User-wide (all workspaces)
mv /tmp/ipsw-skill/ipsw ~/.gemini/config/skills/ipsw
```

Run `/skills` in Antigravity CLI (`agy`) to confirm it loaded. Older Antigravity releases read
`.agent/skills/` instead of `.agents/skills/`. On first launch, `agy` also imports skills already
installed for Gemini CLI.

### Gemini CLI

Google stopped serving Gemini CLI for individual accounts on June 18, 2026; enterprise and paid
API-key users can install the skill natively:

```bash
gemini skills install https://github.com/blacktop/ipsw-skill --path ipsw
```

### Pi (pi-coding-agent)

```bash
# Global (adds package to ~/.pi/agent/settings.json; clones to ~/.pi/agent/git/...)
pi install https://github.com/blacktop/ipsw-skill

# Project-local (adds package to ./.pi/settings.json; clones to ./.pi/git/...)
pi install -l https://github.com/blacktop/ipsw-skill
```

## Updating

Releases use semver (see [CHANGELOG.md](CHANGELOG.md)); `ipsw/SKILL.md` carries the version in
`metadata.version`, along with the ipsw version it describes.

| Installed with | Update |
|---|---|
| skills.sh | `npx skills update` |
| Claude Code plugin | `claude plugin update ipsw@ipsw-skill` (auto-update is off for third-party marketplaces; turn it on under `/plugin` → Marketplaces) |
| Codex plugin | `codex plugin marketplace upgrade ipsw-skill`, then `codex plugin add ipsw@ipsw-skill` |
| Antigravity | re-clone and replace `ipsw/` in the skills directory |
| Gemini CLI | re-run `gemini skills install ... --path ipsw` |
| Pi | `pi update --extensions` |
| Manual copy | re-clone and copy `ipsw/` again |

## Usage Examples

Once installed, the agent will automatically use this skill for Apple RE tasks:

> "What's in the exclave bundle of the latest iPhone 16 Pro IPSW? Don't download the whole thing."

> "Grab just the kernelcache from the newest iOS beta and tell me which KEXTs changed"

> "Disassemble _malloc from the system dyld_shared_cache"

> "What ObjC methods did SpringBoardServices gain between these two caches?"

> "Which sandbox profiles can open IOSurfaceRootUserClient in this kernelcache?"

> "Symbolicate this panic log"

## Contents

```
ipsw-skill/
├── ipsw/                       # The skill (every agent reads this)
│   ├── SKILL.md                # Working rules, workflows, and a map of the references
│   └── references/
│       ├── download.md         # Find URLs, remote reads, downloads, extraction, AEA keys
│       ├── firmware.md         # info/mount/dtree, fw components, IMG4, AEA, OTA payloads
│       ├── dyld.md             # dyld_shared_cache analysis
│       ├── class-dump.md       # ObjC/Swift dumping and API diffs
│       ├── macho.md            # Mach-O analysis, search, signing, patching
│       ├── kernel.md           # Kernelcache and KEXT analysis
│       ├── sandbox.md          # Sandbox profiles and capability queries
│       ├── entitlements.md     # Entitlement search and databases
│       ├── diffing.md          # Release diffs and patch hunting
│       ├── symbolication.md    # Crash and panic symbolication
│       └── device.md           # USB-connected devices (idev)
├── .claude-plugin/             # Claude Code marketplace + plugin manifest
├── .codex-plugin/plugin.json   # Codex plugin manifest
├── .agents/plugins/            # Codex marketplace
├── package.json                # Pi package manifest
├── scripts/check-versions.sh   # CI: all manifests share one version
└── CHANGELOG.md
```

## Resources

- [ipsw Documentation](https://blacktop.github.io/ipsw)
- [ipsw GitHub](https://github.com/blacktop/ipsw)
- [Discord Community](https://discord.gg/BEamsHAWAh)

## License

MIT
