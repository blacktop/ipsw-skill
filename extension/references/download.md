# Firmware Download & Extraction Reference

Complete reference for downloading and extracting Apple firmware with ipsw.

## Which Download Command Do I Need?

```
What do you want to download?
│
├─► iOS/iPadOS/tvOS/watchOS firmware
│   │
│   ├─► Full restore image (.ipsw file)
│   │   └─► ipsw download ipsw
│   │
│   ├─► Over-the-air update (smaller, delta updates)
│   │   └─► ipsw download ota
│   │
│   └─► Just the kernel or dyld_shared_cache (fastest)
│       └─► ipsw download ipsw --kernel --dyld
│           (extracts during download, no full IPSW saved)
│
├─► macOS installer
│   └─► ipsw download macos
│
├─► Kernel Development Kit (debug symbols, type info)
│   └─► ipsw download kdk
│
├─► Apple open source (xnu, dyld, etc.)
│   └─► ipsw download git <project>
│
├─► App Store IPA
│   └─► ipsw download ipa
│
├─► Firmware decryption keys
│   └─► ipsw download keys
│
└─► SHSH blobs / signing status
    └─► ipsw download tss
```

### Quick Decision Guide

| I want to... | Command |
|--------------|---------|
| Get latest iOS kernel for research | `ipsw download ipsw --device <ID> --latest --kernel` |
| Get dyld_shared_cache for class-dump | `ipsw download ipsw --device <ID> --latest --dyld` |
| Download full IPSW for restore | `ipsw download ipsw --device <ID> --latest` |
| Get beta/developer firmware | `ipsw download ota --device <ID> --beta` |
| Analyze macOS internals | `ipsw download macos --latest` |
| Get kernel debug symbols | `ipsw download kdk --latest` |
| Read xnu source code | `ipsw download git xnu` |
| Check if firmware is still signed | `ipsw download tss --device <ID> --build <BUILD>` |

### IPSW vs OTA: When to Use Which

| Criteria | `download ipsw` | `download ota` |
|----------|-----------------|----------------|
| File size | Larger (full image) | Smaller (delta) |
| Contains full filesystem | Yes | Partial |
| Best for kernel extraction | Yes | Yes |
| Best for dyld_shared_cache | Yes | Yes |
| Beta/seed releases | Limited | Yes (`--beta`) |
| Restore device | Yes | No |

---

## Table of Contents
- [IPSW Downloads](#ipsw-downloads)
- [OTA Downloads](#ota-downloads)
- [Remote Extraction](#remote-extraction)
- [Local Extraction](#local-extraction)
- [Kernel Development Kits](#kernel-development-kits)
- [macOS Downloads](#macos-downloads)
- [Other Downloads](#other-downloads)

---

## IPSW Downloads

**Download latest IPSW for device:**
```bash
ipsw download ipsw --device iPhone16,1 --latest
```

**Download specific iOS version:**
```bash
ipsw download ipsw --device iPhone14,2 --version 15.1
```

**Download specific build:**
```bash
ipsw download ipsw --device iPhone11,2 --build 16B92
```

**Download all IPSWs for a version:**
```bash
ipsw download ipsw --version 17.0
```

**Download with kernel extraction:**
```bash
ipsw download ipsw --device iPhone16,1 --latest --kernel
```

**Download with dyld_shared_cache extraction:**
```bash
ipsw download ipsw --device iPhone16,1 --latest --dyld --dyld-arch arm64e
```

**Get download URLs only (no download):**
```bash
ipsw download ipsw --device iPhone16,1 --latest --urls
```

**Resume interrupted download:**
```bash
ipsw download ipsw --device iPhone16,1 --latest --resume-all
```

**Filter by device family:**
```bash
ipsw download ipsw --version 17.0 --white-list iPhone
ipsw download ipsw --version 17.0 --black-list iPad
```

---

## OTA Downloads

**Download latest OTA:**
```bash
ipsw download ota --platform ios --device iPhone16,1 --latest
```

**Download with kernel extraction:**
```bash
ipsw download ota --platform ios --device iPhone16,1 --kernel
```

**Download with dyld_shared_cache:**
```bash
ipsw download ota --platform ios --device iPhone16,1 --dyld
```

**Beta/seed OTAs:**
```bash
ipsw download ota --platform ios --device iPhone16,1 --beta
```

---

## Remote Extraction

Extract components from remote IPSW/OTA without downloading entire file.

**Extract kernel remotely:**
```bash
ipsw extract --kernel --remote https://updates.cdn-apple.com/path/to/ipsw
```

**Extract dyld_shared_cache remotely:**
```bash
ipsw extract --dyld --dyld-arch arm64e --remote https://updates.cdn-apple.com/path/to/ipsw
```

**Extract files matching pattern remotely:**
```bash
ipsw extract --files --pattern '.*\.plist$' --remote https://url/to/ipsw
```

**Get IPSW URL then extract:**
```bash
# Get URL
ipsw download ipsw --device iPhone16,1 --latest --urls

# Extract from URL
ipsw extract --kernel --remote <URL_FROM_ABOVE>
```

---

## Local Extraction

**Extract kernel:**
```bash
ipsw extract --kernel iPhone16,1_18.0_Restore.ipsw
```

**Extract dyld_shared_cache:**
```bash
ipsw extract --dyld --dyld-arch arm64e iPhone16,1_18.0_Restore.ipsw
```

**Extract both kernel and dyld:**
```bash
ipsw extract --kernel --dyld iPhone16,1_18.0_Restore.ipsw
```

**Extract DeviceTree:**
```bash
ipsw extract --dtree iPhone16,1_18.0_Restore.ipsw
```

**Extract iBoot:**
```bash
ipsw extract --iboot iPhone16,1_18.0_Restore.ipsw
```

**Extract SEP firmware:**
```bash
ipsw extract --sep iPhone16,1_18.0_Restore.ipsw
```

**Extract files by pattern:**
```bash
ipsw extract --files --pattern '.*Info\.plist$' iPhone16,1_18.0_Restore.ipsw
```

**Extract to specific directory:**
```bash
ipsw extract --kernel --output ./extracted/ iPhone16,1_18.0_Restore.ipsw
```

**Get system version info:**
```bash
ipsw extract --sys-ver iPhone16,1_18.0_Restore.ipsw
```

**JSON output:**
```bash
ipsw extract --kernel --json iPhone16,1_18.0_Restore.ipsw
```

---

## Kernel Development Kits

KDKs contain debug symbols and type information for kernel analysis.

**List available KDKs:**
```bash
ipsw download kdk --list
```

**Download specific KDK:**
```bash
ipsw download kdk --version 13.0
```

**Download latest KDK:**
```bash
ipsw download kdk --latest
```

After download, use with `ipsw ctfdump` for type analysis:
```bash
ipsw ctfdump /Library/Developer/KDKs/KDK_13.0/kernel.development task
```

---

## macOS Downloads

**Download macOS installer:**
```bash
ipsw download macos --version 14.0
```

**Download latest macOS:**
```bash
ipsw download macos --latest
```

**List available macOS versions:**
```bash
ipsw download macos --list
```

---

## Other Downloads

**Apple open source distributions:**
```bash
ipsw download git xnu
ipsw download git dyld
```

**Firmware keys from iPhone Wiki:**
```bash
ipsw download keys --device iPhone16,1 --build 21A326
```

**SHSH blobs / signing status:**
```bash
ipsw download tss --device iPhone16,1 --build 21A326
```

**App Store IPAs (requires auth):**
```bash
ipsw download ipa --bundle-id com.example.app
```

---

## Device Identifiers

Common device identifiers for downloads:

| Device | Identifier |
|--------|------------|
| iPhone 15 Pro Max | iPhone16,2 |
| iPhone 15 Pro | iPhone16,1 |
| iPhone 15 Plus | iPhone15,5 |
| iPhone 15 | iPhone15,4 |
| iPhone 14 Pro Max | iPhone15,3 |
| iPhone 14 Pro | iPhone15,2 |
| iPad Pro 12.9" (M2) | iPad14,5 |
| iPad Pro 11" (M2) | iPad14,3 |
| Apple Watch Ultra 2 | Watch7,5 |
| Apple TV 4K (3rd) | AppleTV14,1 |

**List all devices:**
```bash
ipsw device-list
```

**Get device info:**
```bash
ipsw device-info iPhone16,1
```

---

## Configuration

Create `~/.ipsw/config.yml` for persistent settings:

```yaml
download:
  resume-all: true
  output: ~/Downloads/ipsw
  proxy: http://proxy.example.com:8080
```

---

## Common Workflows

**Get kernel for latest iOS on iPhone 15 Pro:**
```bash
ipsw download ipsw --device iPhone16,1 --latest --kernel
```

**Build local firmware collection:**
```bash
for device in iPhone16,1 iPhone15,2 iPad14,5; do
    ipsw download ipsw --device $device --latest --kernel --dyld
done
```

**Compare kernels between versions:**
```bash
ipsw download ipsw --device iPhone16,1 --version 17.0 --kernel
ipsw download ipsw --device iPhone16,1 --version 17.1 --kernel
ipsw kernel kexts --diff kernelcache_17.0 kernelcache_17.1
```
