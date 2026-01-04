# dyld_shared_cache Analysis Reference

Complete reference for analyzing Apple's dyld_shared_cache (DSC) with ipsw.

## Table of Contents
- [Finding the DSC](#finding-the-dsc)
- [DSC Info & Structure](#dsc-info--structure)
- [Symbol Lookup](#symbol-lookup)
- [Disassembly](#disassembly)
- [Objective-C Analysis](#objective-c-analysis)
- [String Search](#string-search)
- [Address Conversions](#address-conversions)
- [Cross-References](#cross-references)
- [Extracting Dylibs](#extracting-dylibs)

---

## Finding the DSC

**macOS system DSC location:**
```bash
/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e
```

**iOS DSC (after extraction from IPSW):**
```bash
ipsw extract --dyld --dyld-arch arm64e iPhone16,1_18.0_Restore.ipsw
# Creates: dyld_shared_cache_arm64e
```

**List dylibs in DSC:**
```bash
ipsw dyld info --dylibs dyld_shared_cache_arm64e
```

---

## DSC Info & Structure

**Basic info:**
```bash
ipsw dyld info dyld_shared_cache_arm64e
```

**List all dylibs:**
```bash
ipsw dyld info --dylibs dyld_shared_cache_arm64e
```

**JSON output for scripting:**
```bash
ipsw dyld info --dylibs --json dyld_shared_cache_arm64e
```

**Diff two DSCs (find added/removed dylibs):**
```bash
ipsw dyld info --diff dyld_shared_cache_v1 dyld_shared_cache_v2
```

**Launch closures:**
```bash
ipsw dyld info --closures dyld_shared_cache_arm64e
```

---

## Symbol Lookup

**Find symbol address:**
```bash
ipsw dyld symaddr dyld_shared_cache_arm64e _malloc
```

**Find symbol in specific dylib (faster):**
```bash
ipsw dyld symaddr dyld_shared_cache_arm64e _malloc --image libsystem_malloc.dylib
```

**Find all symbols matching pattern:**
```bash
ipsw dyld symaddr dyld_shared_cache_arm64e --all '_NS.*Error'
```

**Include bind symbols:**
```bash
ipsw dyld symaddr dyld_shared_cache_arm64e _malloc --binds
```

**Batch lookup from JSON file:**
```bash
# Create sym_lookup.json:
# [{"pattern": "_malloc", "image": "libsystem_malloc.dylib"},
#  {"pattern": "_objc_msgSend", "image": "libobjc.A.dylib"}]
ipsw dyld symaddr dyld_shared_cache_arm64e --in sym_lookup.json --output results.json
```

**Address to symbol:**
```bash
ipsw dyld a2s dyld_shared_cache_arm64e 0x1bc39e1e0
```

---

## Disassembly

**Disassemble by symbol name:**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol _malloc
```

**Disassemble with image hint (faster):**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol _NSLog --image Foundation
```

**Disassemble by virtual address:**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --vaddr 0x1b19d6940
```

**Disassemble with demangled symbols:**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol '_$s.*' --demangle
```

**Quiet mode (faster, less verbose):**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol _malloc --quiet
```

**JSON output:**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol _malloc --json
```

**With syntax highlighting (pipe to bat):**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol _malloc --color | bat -l asm
```

**LLM-powered decompilation:**
```bash
ipsw dyld disass dyld_shared_cache_arm64e --symbol _malloc --dec --dec-llm copilot --dec-lang C
```

---

## Objective-C Analysis

**Dump all ObjC classes:**
```bash
ipsw dyld objc --class dyld_shared_cache_arm64e
```

**Dump classes from specific dylib:**
```bash
ipsw dyld objc --class dyld_shared_cache_arm64e --image UIKit
```

**Dump protocols:**
```bash
ipsw dyld objc --proto dyld_shared_cache_arm64e
```

**Dump selectors:**
```bash
ipsw dyld objc --sel dyld_shared_cache_arm64e
```

**Dump imp-caches:**
```bash
ipsw dyld objc --imp-cache dyld_shared_cache_arm64e
```

---

## String Search

**Search for string in DSC:**
```bash
ipsw dyld str dyld_shared_cache_arm64e "error"
```

**Search in specific dylib:**
```bash
ipsw dyld str dyld_shared_cache_arm64e "password" --image Security
```

---

## Address Conversions

**Address to offset:**
```bash
ipsw dyld a2o dyld_shared_cache_arm64e 0x1bc39e1e0
```

**Offset to address:**
```bash
ipsw dyld o2a dyld_shared_cache_arm64e 0x39e1e0
```

**Dump data at virtual address:**
```bash
ipsw dyld dump dyld_shared_cache_arm64e 0x1bc39e1e0 --size 256
```

---

## Cross-References

**Find xrefs to address:**
```bash
ipsw dyld xref dyld_shared_cache_arm64e 0x1813450bc
```

**Search all dylibs for xrefs:**
```bash
ipsw dyld xref dyld_shared_cache_arm64e 0x1813450bc --all
```

**Search specific dylib:**
```bash
ipsw dyld xref dyld_shared_cache_arm64e 0x1813450bc --image UIKit
```

**Find imports from dependent dylibs:**
```bash
ipsw dyld xref dyld_shared_cache_arm64e 0x1813450bc --imports
```

---

## Extracting Dylibs

**Extract single dylib:**
```bash
ipsw dyld extract dyld_shared_cache_arm64e UIKit --output ./extracted/
```

**Extract with ObjC metadata:**
```bash
ipsw dyld extract dyld_shared_cache_arm64e UIKit --objc
```

**Extract with stubs:**
```bash
ipsw dyld extract dyld_shared_cache_arm64e UIKit --stubs
```

**Split entire DSC (requires Xcode):**
```bash
ipsw dyld split dyld_shared_cache_arm64e --output ./split_cache/
```

---

## Performance Tips

1. **Symbol caching**: First symbol lookup creates `.a2s` cache file - subsequent lookups are 10-15x faster
2. **Use --image flag**: Specifying the dylib dramatically speeds up symbol resolution
3. **Use --quiet**: Reduces output verbosity and speeds up disassembly
4. **Batch operations**: Use `--in` flag with JSON for multiple symbol lookups
