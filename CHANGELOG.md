# Changelog

All notable changes to the ipsw skill. Versions follow [semver](https://semver.org/); every
manifest (`ipsw/SKILL.md` metadata, `.claude-plugin/`, `.codex-plugin/`,
`package.json`) carries the same version, checked by `scripts/check-versions.sh`.

## [2.0.0] - 2026-09-27

Written against ipsw 3.1.725 and the fixes in ipsw commit 6e0291a8f.

### Changed
- `SKILL.md` rewritten as working rules, a task map, and short verified workflows; details moved
  into references. Description is now third person.
- Every command and flag checked against `ipsw --help` and runs on real firmware; 41 incorrect
  commands and flags from 1.0.0 fixed (for example `class-dump --re` needs `-V`,
  `dyld disass --symbol-image`, `macho patch add|mod|rm`, `download git --product`).

### Added
- References: `firmware.md` (fw, IMG4, AEA, OTA internals), `diffing.md`, `symbolication.md`,
  `device.md`.
- Remote-first workflows (`info --remote --list`, `fw exclave --remote --info`,
  `extract --remote`), `class-dump --diff` / `swift-dump --diff`, kernel symbolication with and
  without signatures, and an "Older releases" table of workarounds for ipsw 3.1.725 and earlier.
- Codex plugin support: `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`.
- Claude Code `.claude-plugin/plugin.json` with version and metadata.

### Removed
- `compatibility` frontmatter key (rejected by Codex's skill validator); its content is in the
  `SKILL.md` body.
- `gemini-extension.json`. Google stopped serving Gemini CLI for individual accounts on
  2026-06-18; Gemini CLI users install the skill natively (`gemini skills install ... --path ipsw`)
  and Antigravity users copy it into `.agents/skills/`. Existing extension installs no longer
  receive updates.

## [1.0.0] - 2026-05-03

Initial release.
