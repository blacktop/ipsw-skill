# ipsw-skill

An AI agent skill for Apple firmware and binary reverse engineering using the [ipsw](https://github.com/blacktop/ipsw) CLI tool.

Supports **Claude Code**, **Codex CLI**, **Gemini CLI**, and **Pi (pi-coding-agent)**.

## What This Skill Provides

This skill empowers AI agents to assist with:

- **Downloading/extracting firmware** - IPSWs, OTAs, kernelcaches, dyld_shared_cache
- **Userspace reverse engineering** - DSC disassembly, symbol lookup, xrefs, string search
- **Dumping Objective-C headers** from private frameworks
- **Kernel & KEXT analysis** - extraction, syscalls, diffing between versions
- **Entitlements research** - database queries, capability discovery
- **Mach-O binary analysis** - signatures, entitlements, disassembly

## Installation

### Prerequisites

Install the `ipsw` CLI tool:

```bash
brew install blacktop/tap/ipsw
```

### skills.sh

```bash
npx skills add https://github.com/blacktop/ipsw-skill --skill ipsw
```

### Claude Code

Install from marketplace:

```bash
claude plugin marketplace add blacktop/ipsw-skill
claude plugin install ipsw
```

Or install manually:

```bash
git clone https://github.com/blacktop/ipsw-skill /tmp/ipsw-skill

# User-wide (available in all projects)
mv /tmp/ipsw-skill/skill ~/.claude/skills/ipsw

# Project-specific (check into your repo)
mv /tmp/ipsw-skill/skill .claude/skills/ipsw
```

### Codex CLI

Use the built-in installer:

```bash
$skill-installer https://github.com/blacktop/ipsw-skill --path skill
```

Or install manually:

```bash
git clone https://github.com/blacktop/ipsw-skill /tmp/ipsw-skill

# User-wide
mv /tmp/ipsw-skill/skill ~/.codex/skills/ipsw

# Project-specific
mv /tmp/ipsw-skill/skill .codex/skills/ipsw
```

> **Note**: Run Codex with `--enable skills` if skills aren't loading automatically.

### Gemini CLI

Install the extension directly:

```bash
gemini extensions install https://github.com/blacktop/ipsw-skill
```

### Pi (pi-coding-agent)

```bash
# Global (adds package to ~/.pi/agent/settings.json; clones to ~/.pi/agent/git/...)
pi install https://github.com/blacktop/ipsw-skill

# Project-local (adds package to ./.pi/settings.json; clones to ./.pi/git/...)
pi install -l https://github.com/blacktop/ipsw-skill
```

## Usage Examples

Once installed, the agent will automatically use this skill for Apple RE tasks:

> "Download the latest IPSW for iPhone 15 Pro and extract the kernel"

> "Disassemble the _malloc function from the system dyld_shared_cache"

> "Dump the Objective-C headers for SpringBoardServices"

> "Find all binaries with the platform-application entitlement in iOS 18"

> "What address is -[NSObject init] at in the DSC?"

> "Find all xrefs to this function address"

## Contents

```
ipsw-skill/
├── skill/                      # Claude Code / Codex / Pi skill
│   ├── SKILL.md                # Main skill instructions
│   └── references/
│       ├── dyld.md             # DSC analysis (a2s, xref, dump, str)
│       ├── download.md         # Firmware download & extraction
│       ├── kernel.md           # Kernel & KEXT analysis
│       ├── macho.md            # Mach-O binary analysis
│       ├── class-dump.md       # ObjC header dumping
│       └── entitlements.md     # Entitlements database & queries
├── extension/                  # Gemini CLI extension resources
│   └── references/             # (same reference files)
├── GEMINI.md                   # Gemini extension instructions
├── gemini-extension.json       # Gemini extension config
├── package.json                # Pi package manifest
└── .claude-plugin/
    └── marketplace.json        # Claude marketplace config
```

## Resources

- [ipsw Documentation](https://blacktop.github.io/ipsw)
- [ipsw GitHub](https://github.com/blacktop/ipsw)
- [Discord Community](https://discord.gg/BEamsHAWAh)

## License

MIT
