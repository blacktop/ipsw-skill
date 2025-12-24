# ipsw-skill

A Claude Code skill for Apple firmware and binary reverse engineering using the [ipsw](https://github.com/blacktop/ipsw) CLI tool.

## What This Skill Provides

This skill empowers Claude to assist with:

- **Disassembling functions** in dyld_shared_cache and Mach-O binaries
- **Dumping Objective-C headers** from private frameworks
- **Downloading IPSWs/OTAs** and extracting kernelcaches
- **Analyzing entitlements** across iOS/macOS binaries
- **KEXT extraction and analysis** from kernelcaches
- **Tracking changes** between iOS/macOS versions

## Installation

### Prerequisites

Install the `ipsw` CLI tool:

```bash
brew install blacktop/tap/ipsw
```

### Claude Code

Install from the marketplace:

```bash
claude /marketplace install blacktop/ipsw-skill
```

Or install as a plugin directly:

```bash
claude /install-plugin https://github.com/blacktop/ipsw-skill
```

Or install manually by cloning:

```bash
# User-wide (available in all projects)
git clone https://github.com/blacktop/ipsw-skill ~/.claude/plugins/ipsw

# Project-specific (check into your repo)
git clone https://github.com/blacktop/ipsw-skill .claude/plugins/ipsw
```

### Codex CLI

Use the built-in `$skill-installer` to install from GitHub:

```
$skill-installer https://github.com/blacktop/ipsw-skill
```

Or install manually by cloning to a skills directory:

```bash
# User-wide (available in all projects)
git clone https://github.com/blacktop/ipsw-skill ~/.codex/skills/ipsw

# Project-specific (check into your repo)
git clone https://github.com/blacktop/ipsw-skill .codex/skills/ipsw
```

> **Note**: Run Codex with `--enable skills` if skills aren't loading automatically.

## Usage Examples

Once installed, Claude will automatically use this skill when you ask about Apple reverse engineering tasks:

> "Disassemble the _malloc function from the system dyld_shared_cache"

> "Dump the Objective-C headers for SpringBoardServices"

> "Download the latest IPSW for iPhone 15 Pro and extract the kernel"

> "Find all binaries with the platform-application entitlement in iOS 18"

> "Extract the sandbox KEXT from this kernelcache"

> "What classes in Security.framework handle keychain operations?"

## Skill Contents

```
.claude-plugin/
└── plugin.json                 # Plugin metadata
skills/
└── ipsw/
    ├── SKILL.md                # Core workflows and quick reference
    └── references/
        ├── dyld.md             # dyld_shared_cache analysis commands
        ├── macho.md            # Mach-O binary analysis commands
        ├── kernel.md           # Kernel & KEXT analysis commands
        ├── download.md         # Firmware download & extraction
        ├── class-dump.md       # ObjC header dumping
        └── entitlements.md     # Entitlements database & queries
```

## Resources

- [ipsw Documentation](https://blacktop.github.io/ipsw)
- [ipsw GitHub](https://github.com/blacktop/ipsw)
- [Discord Community](https://discord.gg/BEamsHAWAh)

## License

MIT
