# Mach-O Binary Analysis Reference

Complete reference for analyzing Mach-O binaries with ipsw.

## Table of Contents
- [Binary Info](#binary-info)
- [Disassembly](#disassembly)
- [Entitlements](#entitlements)
- [Code Signature](#code-signature)
- [Objective-C Metadata](#objective-c-metadata)
- [Swift Metadata](#swift-metadata)
- [Symbols](#symbols)
- [Address Conversions](#address-conversions)
- [Universal/Fat Binaries](#universalfat-binaries)
- [Fileset Kernelcaches](#fileset-kernelcaches)

---

## Binary Info

**Full MachO info:**
```bash
ipsw macho info /path/to/binary
```

**Header only:**
```bash
ipsw macho info --header /path/to/binary
```

**Load commands:**
```bash
ipsw macho info --loads /path/to/binary
```

**Segments and sections:**
```bash
ipsw macho info --loads /path/to/binary | grep -A5 "LC_SEGMENT"
```

**JSON output:**
```bash
ipsw macho info --json /path/to/binary
```

**Function starts:**
```bash
ipsw macho info --starts /path/to/binary
```

**Fixup chains:**
```bash
ipsw macho info --fixups /path/to/binary
```

**Strings:**
```bash
ipsw macho info --strings /path/to/binary
```

---

## Disassembly

**Disassemble by symbol:**
```bash
ipsw macho disass /path/to/binary --symbol _main
```

**Disassemble by virtual address:**
```bash
ipsw macho disass /path/to/binary --vaddr 0x100001000
```

**Disassemble by file offset:**
```bash
ipsw macho disass /path/to/binary --off 0x4000
```

**Disassemble entry point:**
```bash
ipsw macho disass /path/to/binary --entry
```

**Disassemble entire section:**
```bash
ipsw macho disass /path/to/binary --section __TEXT.__text
```

**Limit instruction count:**
```bash
ipsw macho disass /path/to/binary --symbol _main --count 50
```

**With color:**
```bash
ipsw macho disass /path/to/binary --symbol _main --color
```

**Specific architecture (fat binary):**
```bash
ipsw macho disass /path/to/binary --symbol _main --arch arm64e
```

**JSON output:**
```bash
ipsw macho disass /path/to/binary --symbol _main --json
```

**LLM decompilation:**
```bash
ipsw macho disass /path/to/binary --symbol _main --dec --dec-llm copilot --dec-lang C
```

---

## Entitlements

**Dump entitlements (plist format):**
```bash
ipsw macho info --ent /path/to/binary
```

**Dump DER-encoded entitlements:**
```bash
ipsw macho info --ent-der /path/to/binary
```

**Check for specific entitlement:**
```bash
ipsw macho info --ent /path/to/binary | grep "platform-application"
```

---

## Code Signature

**Full signature info:**
```bash
ipsw macho info --sig /path/to/binary
```

**Dump signing certificate:**
```bash
ipsw macho info --dump-cert /path/to/binary
```

**Sign a binary (ad-hoc):**
```bash
ipsw macho sign /path/to/binary
```

**Sign with entitlements:**
```bash
ipsw macho sign /path/to/binary --ent entitlements.plist
```

**Sign with identity:**
```bash
ipsw macho sign /path/to/binary --id "Apple Development: ..."
```

---

## Objective-C Metadata

**Dump ObjC info:**
```bash
ipsw macho info --objc /path/to/binary
```

**Dump ObjC with references:**
```bash
ipsw macho info --objc-refs /path/to/binary
```

---

## Swift Metadata

**Basic Swift info:**
```bash
ipsw macho info --swift /path/to/binary
```

**All Swift metadata:**
```bash
ipsw macho info --swift-all /path/to/binary
```

---

## Symbols

**Dump all symbols:**
```bash
ipsw macho info --symbols /path/to/binary
```

**Address to symbol:**
```bash
ipsw macho a2s /path/to/binary 0x100001234
```

---

## Address Conversions

**Virtual address to file offset:**
```bash
ipsw macho a2o /path/to/binary 0x100001234
```

**File offset to virtual address:**
```bash
ipsw macho o2a /path/to/binary 0x1234
```

**Dump data at address:**
```bash
ipsw macho dump /path/to/binary 0x100001234 --size 256
```

---

## Universal/Fat Binaries

**List architectures:**
```bash
ipsw macho info --header /path/to/fat_binary
```

**Extract specific architecture:**
```bash
ipsw macho lipo /path/to/fat_binary --arch arm64 --output arm64_binary
```

**Create universal binary:**
```bash
ipsw macho bbl arm64_binary arm64e_binary --output universal_binary
```

---

## Fileset Kernelcaches

Modern kernelcaches use MH_FILESET format containing multiple embedded Mach-O binaries.

**List fileset entries:**
```bash
ipsw macho info --all-fileset-entries /path/to/kernelcache
```

**Analyze specific fileset entry:**
```bash
ipsw macho info --fileset-entry "com.apple.kernel" /path/to/kernelcache
```

**Disassemble from fileset entry:**
```bash
ipsw macho disass /path/to/kernelcache --fileset-entry "com.apple.iokit.IOKit" --symbol _IOLog
```

---

## Patching

**Patch load command:**
```bash
ipsw macho patch /path/to/binary --lc LC_VERSION_MIN_IPHONEOS --set version=14.0
```

**Add rpath:**
```bash
ipsw macho patch /path/to/binary --add-rpath @executable_path/../Frameworks
```

---

## Common Patterns

**Find all binaries with specific entitlement:**
```bash
find /Applications -name "*.app" -exec sh -c 'ipsw macho info --ent "$1/Contents/MacOS/"* 2>/dev/null | grep -l platform-application && echo "$1"' _ {} \;
```

**Analyze all binaries in directory:**
```bash
for f in /path/to/binaries/*; do
    echo "=== $f ==="
    ipsw macho info --header "$f"
done
```
