# Objective-C Class Dumping Reference

Complete reference for dumping Objective-C headers with ipsw.

## Table of Contents
- [Basic Usage](#basic-usage)
- [From dyld_shared_cache](#from-dyld_shared_cache)
- [From Mach-O Binary](#from-mach-o-binary)
- [Filtering Classes](#filtering-classes)
- [Header Generation](#header-generation)
- [Output Formatting](#output-formatting)
- [Swift Dumping](#swift-dumping)

---

## Basic Usage

**From DSC dylib:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit
```

**From standalone Mach-O:**
```bash
ipsw class-dump /path/to/binary
```

---

## From dyld_shared_cache

**Dump specific framework:**
```bash
ipsw class-dump dyld_shared_cache_arm64e Foundation
```

**Dump private framework:**
```bash
ipsw class-dump dyld_shared_cache_arm64e SpringBoardServices
```

**Dump all dylibs:**
```bash
ipsw class-dump dyld_shared_cache_arm64e --all
```

**Common frameworks for RE:**
```bash
# UI frameworks
ipsw class-dump dyld_shared_cache_arm64e UIKit
ipsw class-dump dyld_shared_cache_arm64e SwiftUI

# Security
ipsw class-dump dyld_shared_cache_arm64e Security
ipsw class-dump dyld_shared_cache_arm64e LocalAuthentication

# System services
ipsw class-dump dyld_shared_cache_arm64e SpringBoard
ipsw class-dump dyld_shared_cache_arm64e MobileContainerManager

# Networking
ipsw class-dump dyld_shared_cache_arm64e CFNetwork
ipsw class-dump dyld_shared_cache_arm64e Network
```

---

## From Mach-O Binary

**Dump app binary:**
```bash
ipsw class-dump /Applications/Example.app/Contents/MacOS/Example
```

**Dump framework:**
```bash
ipsw class-dump /System/Library/Frameworks/Foundation.framework/Foundation
```

**Dump daemon:**
```bash
ipsw class-dump /usr/libexec/securityd
```

---

## Filtering Classes

**Filter by class name regex:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --class 'UIView.*'
```

**Filter by protocol regex:**
```bash
ipsw class-dump dyld_shared_cache_arm64e Foundation --proto 'NSCoding'
```

**Filter by category regex:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --cat 'UIView.*'
```

**Combine filters:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --class 'UITableView.*' --proto 'UITableViewDelegate'
```

---

## Header Generation

**Generate ObjC headers:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --headers --output ./headers/
```

**Generate headers for all frameworks:**
```bash
ipsw class-dump dyld_shared_cache_arm64e --all --headers --output ./all_headers/
```

**Include dependencies (private frameworks):**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --headers --deps --output ./headers/
```

**Include references:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --headers --refs --output ./headers/
```

---

## Output Formatting

**With addresses (verbose/RE mode):**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --re
```

Shows method addresses useful for hooking/patching.

**With demangled names:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --demangle
```

**Color themes:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --theme nord
ipsw class-dump dyld_shared_cache_arm64e UIKit --theme github
```

---

## Swift Dumping

**Swift class-dump (WIP):**
```bash
ipsw swift-dump dyld_shared_cache_arm64e SwiftUI
```

**Swift from Mach-O:**
```bash
ipsw swift-dump /path/to/swift_binary
```

---

## Common Research Patterns

**Find security-related classes:**
```bash
ipsw class-dump dyld_shared_cache_arm64e Security --class '.*Keychain.*'
ipsw class-dump dyld_shared_cache_arm64e Security --class '.*Trust.*'
ipsw class-dump dyld_shared_cache_arm64e Security --class '.*Credential.*'
```

**Find network classes:**
```bash
ipsw class-dump dyld_shared_cache_arm64e CFNetwork --class '.*URL.*'
ipsw class-dump dyld_shared_cache_arm64e CFNetwork --class '.*HTTP.*'
```

**Find UI controllers:**
```bash
ipsw class-dump dyld_shared_cache_arm64e UIKit --class '.*ViewController$'
```

**Dump private APIs:**
```bash
# SpringBoard internals
ipsw class-dump dyld_shared_cache_arm64e SpringBoardServices --headers --output ./sb_headers/

# Biometric authentication
ipsw class-dump dyld_shared_cache_arm64e BiometricKit --headers --output ./bio_headers/

# App installation
ipsw class-dump dyld_shared_cache_arm64e MobileInstallation --headers --output ./install_headers/
```

**Compare class interfaces between iOS versions:**
```bash
ipsw class-dump dsc_17.0 UIKit --class UITableView > UITableView_17.0.h
ipsw class-dump dsc_17.1 UIKit --class UITableView > UITableView_17.1.h
diff UITableView_17.0.h UITableView_17.1.h
```

---

## Tips

1. **Use --re for hooking**: The `--re` flag shows method addresses needed for runtime hooking
2. **Start specific**: Use `--class` filter first, then broaden if needed
3. **Check dependencies**: Many classes reference private frameworks; use `--deps` to include them
4. **Headers for Xcode**: Generated headers can be used in Xcode projects for private API access
