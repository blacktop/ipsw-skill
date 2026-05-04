---
name: ipsw
description: Use this skill when reverse-engineering Apple platforms with the ipsw CLI — analyzing iOS/macOS Mach-O binaries, disassembling functions inside dyld_shared_cache (DSC), dumping Objective-C/Swift headers from private frameworks, extracting kernelcaches, KEXTs, SEP, iBoot, or DeviceTree from IPSWs/OTAs, decompiling/querying sandbox profiles (SBPL), querying entitlements, symbolicating crashes/panics, diffing two firmware versions, mounting IPSW DMGs, or downloading Apple firmware. Triggers on iOS/macOS internals, kernel research, dyld_shared_cache, KEXT diffing, sandbox/Seatbelt profile analysis (SBPL/SBASM/sandboxd), capability/IOKit queries, entitlement lookup, class-dump, IMG4/AEA handling, or vulnerability research on Apple platforms.
---

# IPSW - Apple Reverse Engineering Toolkit

**Install:** `brew install blacktop/tap/ipsw` (Linux: see https://github.com/blacktop/ipsw#install)

## Choose Your Workflow

| Goal | Start Here |
|------|------------|
| Download/extract firmware | [Firmware Acquisition](#firmware-acquisition) |
| Reverse engineer userspace | [Userspace RE](#userspace-re-dyld_shared_cache) |
| Analyze kernel/KEXTs | [Kernel Analysis](#kernel-analysis) |
| Research entitlements | [Entitlements](#entitlements) |
| Dump private API headers | [Class Dump](#class-dump) |
| Analyze standalone binary | [Mach-O Analysis](#mach-o-analysis) |
| Diff two IPSWs/OTAs | [Firmware Diffing](#firmware-diffing) |
| Symbolicate a crash / panic | [Symbolication](#symbolication) |
| Parse IMG4/AEA/iBoot/SEP | [Firmware Components](#firmware-components-img4-aea-iboot-sep) |
| Decompile / query sandbox profiles | [Sandbox Profile Analysis](#sandbox-profile-analysis-sb) |
| Inspect / mount an IPSW | [IPSW Inspection](#ipsw-inspection) |

---

## Firmware Acquisition

```bash
# Download latest IPSW for device
ipsw download ipsw --device iPhone16,1 --latest

# Download with automatic kernel/DSC extraction
ipsw download ipsw --device iPhone16,1 --latest --kernel --dyld

# Extract components from local IPSW
ipsw extract --kernel iPhone16,1_18.0_Restore.ipsw
ipsw extract --dyld --dyld-arch arm64e iPhone16,1_18.0_Restore.ipsw

# Remote extraction (no full download)
ipsw extract --kernel --remote <IPSW_URL>
```

See [references/download.md](references/download.md) for device identifiers and advanced options.

---

## Userspace RE (dyld_shared_cache)

**macOS DSC location:**
- macOS 14+: `/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e`
- macOS 13 and earlier: `/System/Library/dyld/dyld_shared_cache_arm64e`

Examples below assume:
```bash
export DSC=/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `dyld a2s <DSC> <ADDR>` | Address → symbol (triage crash LR/PC) |
| `dyld symaddr <DSC> <SYM> --image <DYLIB>` | Symbol → address |
| `dyld disass <DSC> --vaddr <ADDR>` | Disassemble at address |
| `dyld disass <DSC> --symbol <SYM> --image <DYLIB>` | Disassemble by symbol |
| `dyld xref <DSC> <ADDR> --all` | Find all references to address |
| `dyld dump <DSC> <ADDR> --size 256` | Dump raw bytes at address |
| `dyld str <DSC> "pattern" --image <DYLIB>` | Search strings |
| `dyld objc --class <DSC> --image <DYLIB>` | List ObjC classes |
| `dyld extract <DSC> <DYLIB> -o ./out/` | Extract dylib for external tools |

### Common Workflow

```bash
# 1. Resolve address from crash/trace
ipsw dyld a2s $DSC 0x1bc39e1e0
# → -[SomeClass someMethod:] + 0x40

# 2. Disassemble around that address
ipsw dyld disass $DSC --vaddr 0x1bc39e1e0

# 3. Find who calls this function
ipsw dyld xref $DSC 0x1bc39e1a0 --all

# 4. Extract string/data referenced in disassembly
ipsw dyld dump $DSC 0x1bc39e200 --size 64
```

See [references/dyld.md](references/dyld.md) for complete DSC commands.

---

## Kernel Analysis

```bash
# List all KEXTs
ipsw kernel kexts kernelcache.release.iPhone16,1

# Extract specific KEXT
ipsw kernel extract kernelcache sandbox --output ./kexts/

# Dump syscalls
ipsw kernel syscall kernelcache

# Diff KEXTs between versions
ipsw kernel kexts --diff kernelcache_17.0 kernelcache_18.0
```

See [references/kernel.md](references/kernel.md) for KEXT extraction and kernel analysis.

---

## Entitlements

```bash
# Single binary entitlements
ipsw macho info --ent /path/to/binary

# Build searchable database from IPSW
ipsw ent --sqlite ent.db --ipsw iOS18.ipsw

# Query database
ipsw ent --sqlite ent.db --key "com.apple.private.security.no-sandbox"
ipsw ent --sqlite ent.db --key "platform-application"
ipsw ent --sqlite ent.db --key "com.apple.private.tcc.manager"
```

See [references/entitlements.md](references/entitlements.md) for common entitlements and query patterns.

---

## Class Dump

Dump Objective-C headers from binaries or dyld_shared_cache:

```bash
# Dump all headers from framework in DSC
ipsw class-dump $DSC SpringBoardServices --headers -o ./headers/

# Dump specific class
ipsw class-dump $DSC Security --class SecKey

# Filter by pattern
ipsw class-dump $DSC UIKit --class 'UIApplication.*' --headers -o ./headers/

# Include runtime addresses (for hooking)
ipsw class-dump $DSC Security --re

# Swift class-dump (separate command, same shape)
ipsw swift-dump $DSC SwiftUI --headers -o ./headers/
```

See [references/class-dump.md](references/class-dump.md) for filtering and output options.

---

## Mach-O Analysis

```bash
# Full binary info
ipsw macho info /path/to/binary

# Disassemble function
ipsw macho disass /path/to/binary --symbol _main

# Get entitlements and signature
ipsw macho info --ent /path/to/binary
ipsw macho info --sig /path/to/binary
```

See [references/macho.md](references/macho.md) for complete Mach-O commands.

---

## Firmware Diffing

Compare two IPSWs, OTAs, or patched OTA directories — surfaces added/removed binaries, entitlement changes, function-starts deltas, and KEXT diffs.

```bash
# Diff two IPSWs (markdown report)
ipsw diff old.ipsw new.ipsw --output ./diff/ --markdown

# Include firmware components (iBoot, SEP, etc.) and launchd configs
ipsw diff old.ipsw new.ipsw --fw --launchd --output ./diff/ --markdown

# Diff with KDKs for kernel symbol resolution
ipsw diff old.ipsw new.ipsw --output ./diff/ --markdown \
  --kdk <OLD_KDK>/System/Library/Kernels/kernel.release.t6031 \
  --kdk <NEW_KDK>/System/Library/Kernels/kernel.release.t6031

# Entitlement-only diff
ipsw diff old.ipsw new.ipsw --ent --output ./diff/

# Diff two OTAs (macOS 14+ AEA-encrypted; supply key DB)
ipsw diff old.ota new.ota --key-db keys.json --output ./diff/ --markdown
```

---

## Symbolication

```bash
# Symbolicate a panic / crash log against an IPSW
ipsw symbolicate panic-full-2024-03-21.ips iPhone16,1_18.0_Restore.ipsw

# Show disassembly around panic frames
ipsw symbolicate panic.ips firmware.ipsw --peek --peek-count 10

# Symbolicate against a DSC instead
ipsw symbolicate crash.ips $DSC
```

---

## Firmware Components (IMG4, AEA, iBoot, SEP)

For Apple firmware containers — IMG4/IM4P/IM4M, AEA1-encrypted DMGs, iBoot, SEP, AOP, DCP, baseband, and trust caches:

```bash
# IMG4 / IM4P / IM4M operations
ipsw img4 info my.img4
ipsw img4 extract --im4p my.img4 --output ./             # IM4P payload (decompressed)
ipsw img4 extract --im4p --im4m --im4r my.img4 -o ./     # All components

# Firmware sub-binaries (iBoot, exclave, AOP, GPU, DCP, baseband)
ipsw fw iboot iBoot.img4
ipsw fw aea --info encrypted.dmg.aea     # AEA1 DMG metadata
ipsw fw aea --key encrypted.dmg.aea       # Pull decryption key
ipsw fw tc TrustCache.img4                # Dump trust cache entries
```

See `ipsw img4 --help` and `ipsw fw --help` for the full list of subcommands.

---

## Sandbox Profile Analysis (`sb`)

Decode and query Apple sandbox profiles compiled into a kernelcache. Useful for capability analysis ("which profiles can open IOSurface?"), attack-surface mapping, and tracking sandbox changes between releases.

```bash
# List every profile in a kernelcache
ipsw sb list kernelcache.release.iPhone18,1

# Decompile one profile to SBPL (Sandbox Profile Language)
ipsw sb dec kernelcache.release.iPhone18,1 com.apple.WebKit.WebContent -O WebContent.sb

# Diff sandbox operations between two kernels (find new/removed checks)
ipsw sb opts --diff kernelcache_old kernelcache_new

# Build the cross-profile graph once, then query repeatedly (queries become sub-second)
ipsw sb graph export kernelcache.release.iPhone18,1 -O graph.json

# Capability queries against the graph
ipsw sb query iokit-open IOSurfaceRootUserClient --graph graph.json
ipsw sb query path-write /private/var/mobile/tmp --graph graph.json
ipsw sb query syscall mmap --graph graph.json
ipsw sb query mach-lookup com.apple.mobilegestalt.xpc --graph graph.json
```

Available query subcommands: `iokit-open`, `path-read`, `path-write`, `syscall`, `sysctl`, `mach-lookup`, `mach-register`, `preference`, `notification`, `cypher`.

See [references/sandbox.md](references/sandbox.md) for the full sandbox toolkit.

---

## IPSW Inspection

```bash
# Summarize an IPSW/OTA (devices, builds, file list)
ipsw info iPhone16,1_18.0_Restore.ipsw
ipsw info --list iPhone16,1_18.0_Restore.ipsw       # full file listing
ipsw info --remote <IPSW_URL>                        # without downloading

# Mount the filesystem / system / dyld_shared_cache DMG
ipsw mount fs iPhone16,1_18.0_Restore.ipsw           # filesystem
ipsw mount sys iPhone16,1_18.0_Restore.ipsw          # system
ipsw mount exc iPhone16,1_18.0_Restore.ipsw          # dyld_shared_cache (cryptex)

# Parse the DeviceTree
ipsw dtree iPhone16,1_18.0_Restore.ipsw --summary
ipsw dtree iPhone16,1_18.0_Restore.ipsw --json | jq '.["device-tree"]["compatible"]'
```

For AEA-encrypted DMGs (macOS 14+), pass `--key-db keys.json` or `--pem-db pem.json`.

---

## Pitfalls

1. **Symbol cache must be primed.** First `dyld a2s`/`symaddr` on a DSC creates `<dsc>.a2s`. Until then lookups appear to "find nothing". Run `dyld a2s $DSC <any-addr>` once before scripting bulk lookups.
2. **AEA-encrypted IPSWs/OTAs.** Modern macOS OTAs can ship as AEA1 archives. Pass `--key-val <base64>` or `--key-db keys.json` to commands that need to read them (`diff`, `extract`, `fw aea`).
3. **Always pass `--image <DYLIB>`** for DSC ops. Without it, ipsw walks every dylib map — 10x+ slower.
4. **Multi-arch DSCs need `--dyld-arch`.** Without it, extraction may pick the wrong slice (arm64 vs arm64e) silently.

---

## Reference Files

- [references/download.md](references/download.md) - Firmware download, device IDs, extraction
- [references/dyld.md](references/dyld.md) - Complete DSC commands (a2s, xref, dump, str, extract)
- [references/kernel.md](references/kernel.md) - Kernel and KEXT analysis
- [references/entitlements.md](references/entitlements.md) - Entitlements database and queries
- [references/class-dump.md](references/class-dump.md) - ObjC header dumping
- [references/macho.md](references/macho.md) - Mach-O binary analysis
- [references/sandbox.md](references/sandbox.md) - Sandbox profiles (`sb`): decompile, diff, graph, capability queries

## Tips

1. **JSON output:** Most commands support `--json` for scripting (e.g. `ipsw dyld info --dylibs --json $DSC | jq -r '.images[].name'`).
2. **Device IDs:** `ipsw device-list` lists every known identifier; `ipsw device-info iPhone16,1` describes a specific one.
