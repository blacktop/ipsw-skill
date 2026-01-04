# Kernel & KEXT Analysis Reference

Complete reference for analyzing kernelcaches and kernel extensions with ipsw.

## Table of Contents
- [Kernelcache Basics](#kernelcache-basics)
- [KEXT Extraction](#kext-extraction)
- [KEXT Comparison](#kext-comparison)
- [Syscalls & Mach Traps](#syscalls--mach-traps)
- [MIG Subsystems](#mig-subsystems)
- [Symbolication](#symbolication)
- [CTF/DWARF Analysis](#ctfdwarf-analysis)
- [Kernel Disassembly](#kernel-disassembly)

---

## Kernelcache Basics

**Get kernelcache version:**
```bash
ipsw kernel version kernelcache.release.iPhone15,2
```

**Decompress kernelcache:**
```bash
ipsw kernel dec kernelcache.release.iPhone15,2 --output kernelcache.decompressed
```

**List kernel extensions:**
```bash
ipsw kernel kexts kernelcache.release.iPhone15,2
```

**JSON output:**
```bash
ipsw kernel kexts --json kernelcache.release.iPhone15,2
```

---

## KEXT Extraction

**Extract specific KEXT:**
```bash
ipsw kernel extract kernelcache.release.iPhone15,2 sandbox
```

**Extract KEXT to specific directory:**
```bash
ipsw kernel extract kernelcache.release.iPhone15,2 sandbox --output ./kexts/
```

**Extract all KEXTs:**
```bash
ipsw kernel extract kernelcache.release.iPhone15,2 --all --output ./kexts/
```

**Extract with specific architecture:**
```bash
ipsw kernel extract kernelcache.release.iPhone15,2 IOKit --arch arm64e
```

**Common security-relevant KEXTs:**
```bash
# Sandbox
ipsw kernel extract kernelcache sandbox

# AppleMobileFileIntegrity (code signing)
ipsw kernel extract kernelcache AppleMobileFileIntegrity

# IOKit base
ipsw kernel extract kernelcache com.apple.iokit.IOKit

# Networking
ipsw kernel extract kernelcache com.apple.iokit.IONetworkingFamily
```

---

## KEXT Comparison

**Diff KEXTs between versions:**
```bash
ipsw kernel kexts --diff kernelcache_18A8395 kernelcache_18E5178a
```

Output shows:
- Added KEXTs
- Removed KEXTs
- Version changes

---

## Syscalls & Mach Traps

**Dump syscall table:**
```bash
ipsw kernel syscall kernelcache.release.iPhone15,2
```

**Dump mach_traps:**
```bash
ipsw kernel mach kernelcache.release.iPhone15,2
```

**Search for specific syscall:**
```bash
ipsw kernel syscall kernelcache.release.iPhone15,2 | grep execve
```

---

## MIG Subsystems

**Dump MIG subsystems:**
```bash
ipsw kernel mig kernelcache.release.iPhone15,2
```

MIG (Mach Interface Generator) subsystems define IPC interfaces for kernel services.

---

## Symbolication

**Symbolicate kernelcache:**
```bash
ipsw kernel symbolicate kernelcache.release.iPhone15,2
```

**Dump symbol sets:**
```bash
ipsw kernel symbolsets kernelcache.release.iPhone15,2
```

---

## CTF/DWARF Analysis

CTF (Compact C Type Format) and DWARF provide kernel type information useful for reverse engineering.

**Requires KDK (Kernel Development Kit)**

**Download KDK:**
```bash
ipsw download kdk --version 13.0
```

**Dump type info:**
```bash
ipsw ctfdump KDK/kernel.development.t8101 task > task.h
```

**Dump all kernel types:**
```bash
ipsw ctfdump KDK/kernel.development.t8101 --all
```

**Diff struct between versions:**
```bash
ipsw kernel dwarf --diff --type task KDK_13.0/kernel KDK_13.1/kernel
```

Shows:
- Added/removed struct fields
- Offset changes
- Size changes

---

## Kernel Disassembly

**Disassemble kernel function:**
```bash
ipsw macho disass kernelcache.release.iPhone15,2 --symbol _kernel_bootstrap
```

**From fileset entry (modern kernelcaches):**
```bash
ipsw macho disass kernelcache.release.iPhone15,2 --fileset-entry "com.apple.kernel" --symbol _kernel_bootstrap
```

**IOKit function:**
```bash
ipsw macho disass kernelcache.release.iPhone15,2 --fileset-entry "com.apple.iokit.IOKit" --symbol _IOLog
```

**KEXT function:**
```bash
ipsw macho disass kernelcache.release.iPhone15,2 --fileset-entry "com.apple.security.sandbox" --symbol _sandbox_check
```

---

## Common Research Patterns

**Find sandbox hooks:**
```bash
ipsw kernel extract kernelcache sandbox
ipsw macho info --symbols sandbox.kext | grep "hook\|policy"
```

**Analyze AMFI:**
```bash
ipsw kernel extract kernelcache AppleMobileFileIntegrity
ipsw macho info --symbols AppleMobileFileIntegrity.kext | grep "verify\|trust\|sign"
```

**Track kernel changes between versions:**
```bash
# Extract from two versions
ipsw kernel extract kernelcache_v1 sandbox --output v1/
ipsw kernel extract kernelcache_v2 sandbox --output v2/

# Compare symbols
diff <(ipsw macho info --symbols v1/sandbox.kext) \
     <(ipsw macho info --symbols v2/sandbox.kext)
```

**Find IOUserClient subclasses:**
```bash
ipsw macho info --objc kernelcache.release.iPhone15,2 | grep "IOUserClient"
```
