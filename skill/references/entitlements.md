# Entitlements Analysis Reference

Complete reference for analyzing and searching entitlements with ipsw.

## Table of Contents
- [Single Binary Entitlements](#single-binary-entitlements)
- [Entitlements Database](#entitlements-database)
- [Database Queries](#database-queries)
- [Common Entitlements](#common-entitlements)

---

## Single Binary Entitlements

**Dump entitlements from binary:**
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

## Entitlements Database

Build a searchable database of entitlements across multiple IPSWs.

**Create SQLite database:**
```bash
ipsw ent --sqlite entitlements.db --ipsw iPhone16,1_18.0_Restore.ipsw
```

**Add multiple IPSWs:**
```bash
ipsw ent --sqlite entitlements.db --ipsw *.ipsw
```

**Create PostgreSQL database:**
```bash
ipsw ent --pg-host db.example.com --pg-user postgres --ipsw *.ipsw
```

**From folder of Mach-O binaries:**
```bash
ipsw ent --sqlite entitlements.db --input ./extracted_binaries/
```

**Replace existing builds (update database):**
```bash
ipsw ent --sqlite entitlements.db --ipsw new_version.ipsw --replace
```

**Dry run (preview without changes):**
```bash
ipsw ent --sqlite entitlements.db --ipsw new.ipsw --replace --dry-run
```

---

## Database Queries

**Search by entitlement key:**
```bash
ipsw ent --sqlite entitlements.db --key platform-application
```

**Search by entitlement value:**
```bash
ipsw ent --sqlite entitlements.db --value LockdownMode
```

**Search by file name:**
```bash
ipsw ent --sqlite entitlements.db --file WebContent
```

**Filter by iOS version:**
```bash
ipsw ent --sqlite entitlements.db --key com.apple.private.security.sandbox --version 18.0
```

**Limit results:**
```bash
ipsw ent --sqlite entitlements.db --key sandbox --limit 100
```

**Get statistics:**
```bash
ipsw ent --sqlite entitlements.db --stats
```

---

## Common Entitlements

### Security & Privileges

| Entitlement | Description |
|-------------|-------------|
| `platform-application` | App runs as platform binary |
| `com.apple.private.security.no-sandbox` | Exempt from sandbox |
| `com.apple.private.skip-library-validation` | Skip library signature validation |
| `com.apple.rootless.install` | Can modify SIP-protected files |
| `com.apple.rootless.storage.TCC` | Access TCC database |

### Hardware & System

| Entitlement | Description |
|-------------|-------------|
| `com.apple.developer.kernel.*` | Kernel-related capabilities |
| `com.apple.private.amfi.*` | AMFI bypass capabilities |
| `com.apple.private.memorystatus` | Memory management |
| `com.apple.private.iokit-user-client-class` | IOKit user client access |

### Data & Privacy

| Entitlement | Description |
|-------------|-------------|
| `com.apple.private.tcc.manager` | TCC database management |
| `com.apple.private.tcc.allow` | TCC bypass for specific services |
| `keychain-access-groups` | Keychain access |
| `com.apple.private.MobileContainerManager.allowed` | Container access |

### Networking

| Entitlement | Description |
|-------------|-------------|
| `com.apple.private.network.socket-access` | Raw socket access |
| `com.apple.private.network.restricted.ports` | Bind to privileged ports |
| `com.apple.private.necp.match` | Network extension control |

---

## Research Patterns

**Find all platform binaries:**
```bash
ipsw ent --sqlite ent.db --key platform-application
```

**Find sandbox escapes:**
```bash
ipsw ent --sqlite ent.db --key "com.apple.private.security.no-sandbox"
ipsw ent --sqlite ent.db --key "com.apple.private.security.sandbox"
```

**Find TCC bypasses:**
```bash
ipsw ent --sqlite ent.db --key "com.apple.private.tcc"
```

**Find kernel capabilities:**
```bash
ipsw ent --sqlite ent.db --key "com.apple.developer.kernel"
ipsw ent --sqlite ent.db --key "com.apple.private.kernel"
```

**Track entitlement changes between versions:**
```bash
# Build databases for each version
ipsw ent --sqlite ent_17.0.db --ipsw iOS17.0.ipsw
ipsw ent --sqlite ent_17.1.db --ipsw iOS17.1.ipsw

# Query and compare
ipsw ent --sqlite ent_17.0.db --key "sandbox" > ent_17.0.txt
ipsw ent --sqlite ent_17.1.db --key "sandbox" > ent_17.1.txt
diff ent_17.0.txt ent_17.1.txt
```

**Find new private entitlements:**
```bash
ipsw ent --sqlite ent.db --key "com.apple.private" --version 18.0
```

---

## Tips

1. **Build comprehensive database**: Include multiple iOS versions to track entitlement evolution
2. **Focus on private entitlements**: `com.apple.private.*` often indicates interesting capabilities
3. **Check file context**: Match entitlements with binary functionality for attack surface analysis
4. **Cross-reference with sandbox**: Entitlements often correlate with sandbox profiles
