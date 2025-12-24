---
name: ipsw
description: Apple firmware and binary reverse engineering with the ipsw CLI tool. Use when analyzing iOS/macOS binaries, disassembling functions in dyld_shared_cache, dumping Objective-C headers from private frameworks, downloading IPSWs or kernelcaches, extracting entitlements, analyzing Mach-O files, or researching Apple security. Triggers on requests involving Apple RE, iOS internals, kernel analysis, KEXT extraction, or vulnerability research on Apple platforms.
---

# IPSW - Apple Reverse Engineering Toolkit

The `ipsw` CLI tool provides comprehensive capabilities for Apple firmware and binary analysis: downloading firmware, extracting components, disassembling code, dumping ObjC headers, and analyzing entitlements.

**Installation:** `brew install blacktop/tap/ipsw`

## Quick Reference

| Task | Command |
|------|---------|
| Disassemble DSC function | `ipsw dyld disass <DSC> --symbol <SYM>` |
| Dump ObjC headers | `ipsw class-dump <DSC> <DYLIB> --headers -o ./headers/` |
| Download IPSW | `ipsw download ipsw --device <ID> --latest` |
| Extract kernel | `ipsw extract --kernel <IPSW>` |
| Get entitlements | `ipsw macho info --ent <BINARY>` |
| List KEXTs | `ipsw kernel kexts <KERNELCACHE>` |
| Symbol lookup | `ipsw dyld symaddr <DSC> <SYMBOL>` |

## Core Workflows

### 1. Analyze System dyld_shared_cache

```bash
# macOS DSC location
DSC="/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e"

# List all dylibs
ipsw dyld info --dylibs $DSC

# Find symbol address
ipsw dyld symaddr $DSC _objc_msgSend

# Disassemble function
ipsw dyld disass $DSC --symbol _NSLog --image Foundation

# Dump ObjC class
ipsw class-dump $DSC Security --class SecKey
```

See [references/dyld.md](references/dyld.md) for complete DSC commands.

### 2. Dump Private Framework Headers

```bash
# Extract from system DSC
ipsw class-dump $DSC SpringBoardServices --headers --output ./headers/

# Filter specific classes
ipsw class-dump $DSC UIKit --class 'UIApplication.*' --headers -o ./headers/

# Include addresses for hooking
ipsw class-dump $DSC Security --re
```

See [references/class-dump.md](references/class-dump.md) for filtering and output options.

### 3. Download and Extract Firmware

```bash
# Download latest IPSW with kernel
ipsw download ipsw --device iPhone16,1 --latest --kernel

# Extract dyld_shared_cache
ipsw extract --dyld --dyld-arch arm64e iPhone16,1_18.0_Restore.ipsw

# Remote extraction (no full download)
ipsw extract --kernel --remote https://cdn.apple.com/path/to/ipsw
```

See [references/download.md](references/download.md) for download options and device identifiers.

### 4. Kernel & KEXT Analysis

```bash
# List kernel extensions
ipsw kernel kexts kernelcache.release.iPhone16,1

# Extract specific KEXT
ipsw kernel extract kernelcache sandbox --output ./kexts/

# Dump syscalls
ipsw kernel syscall kernelcache

# Compare KEXTs between versions
ipsw kernel kexts --diff kernelcache_17.0 kernelcache_17.1
```

See [references/kernel.md](references/kernel.md) for KEXT extraction and kernel analysis.

### 5. Mach-O Binary Analysis

```bash
# Full binary info
ipsw macho info /path/to/binary

# Disassemble function
ipsw macho disass /path/to/binary --symbol _main

# Get entitlements
ipsw macho info --ent /path/to/binary

# Code signature
ipsw macho info --sig /path/to/binary
```

See [references/macho.md](references/macho.md) for complete Mach-O commands.

### 6. Entitlements Research

```bash
# Single binary
ipsw macho info --ent /path/to/binary

# Build searchable database
ipsw ent --sqlite ent.db --ipsw *.ipsw

# Find platform binaries
ipsw ent --sqlite ent.db --key platform-application

# Find sandbox escapes
ipsw ent --sqlite ent.db --key "com.apple.private.security.no-sandbox"
```

See [references/entitlements.md](references/entitlements.md) for database queries and common entitlements.

## Common Research Scenarios

### Find Attack Surface in Framework

```bash
# 1. Dump headers to understand interface
ipsw class-dump $DSC TargetFramework --headers -o ./headers/

# 2. Find interesting classes
ipsw class-dump $DSC TargetFramework --class '.*Handler.*'

# 3. Disassemble specific method
ipsw dyld disass $DSC --symbol '-[TargetClass handleInput:]' --image TargetFramework
```

### Analyze Security Daemon

```bash
# 1. Get entitlements
ipsw macho info --ent /usr/libexec/securityd

# 2. Dump ObjC interface
ipsw class-dump /usr/libexec/securityd

# 3. Find Mach services
ipsw macho info --objc /usr/libexec/securityd | grep -i service
```

### Track Changes Between iOS Versions

```bash
# Download both versions
ipsw download ipsw --device iPhone16,1 --version 17.0 --kernel --dyld
ipsw download ipsw --device iPhone16,1 --version 17.1 --kernel --dyld

# Compare KEXTs
ipsw kernel kexts --diff kernelcache_17.0 kernelcache_17.1

# Compare class interface
ipsw class-dump dsc_17.0 UIKit --class UIApplication > v17.0.h
ipsw class-dump dsc_17.1 UIKit --class UIApplication > v17.1.h
diff v17.0.h v17.1.h
```

### Find Binaries with Specific Capability

```bash
# Build entitlements database
ipsw ent --sqlite ent.db --ipsw iOS18.ipsw

# Find TCC managers
ipsw ent --sqlite ent.db --key "com.apple.private.tcc.manager"

# Find kernel capabilities
ipsw ent --sqlite ent.db --key "com.apple.developer.kernel"
```

## Reference Files

- [references/dyld.md](references/dyld.md) - dyld_shared_cache analysis
- [references/macho.md](references/macho.md) - Mach-O binary analysis
- [references/kernel.md](references/kernel.md) - Kernel and KEXT analysis
- [references/download.md](references/download.md) - Firmware download and extraction
- [references/class-dump.md](references/class-dump.md) - ObjC header dumping
- [references/entitlements.md](references/entitlements.md) - Entitlements analysis

## Tips

1. **Symbol caching**: First DSC symbol lookup creates `.a2s` cache - subsequent lookups are 10x faster
2. **Use --image flag**: Specifying dylib dramatically speeds up DSC operations
3. **Remote extraction**: Extract kernel/DSC from URL without full IPSW download
4. **JSON output**: Most commands support `--json` for scripting
5. **Device IDs**: Use `ipsw device-list` to find device identifiers
