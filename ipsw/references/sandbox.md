# Sandbox Profile Analysis (`ipsw sb`)

Decode, query, and diff Apple sandbox profiles compiled into a kernelcache. Useful for capability analysis, attack-surface mapping, and tracking sandbox changes between iOS/macOS releases.

## Subcommand Map

| Command | Purpose |
|---------|---------|
| `sb list <KC>` | List every sandbox profile name in a kernelcache |
| `sb opts <KC>` | List all sandbox operations defined in a kernelcache |
| `sb opts --diff <KC1> <KC2>` | Diff operations between two kernels (find new/removed checks) |
| `sb dec <KC> [PROFILE]` | Decompile profile(s) to SBPL/SBASM/JSON |
| `sb dump <KC>` | Extract raw sandbox blobs (collection, profile, protobox) for offline use |
| `sb cmpl <SB>` | Compile a `.sb` source profile to a `profile.bin` blob |
| `sb check <PID>` | Check sandbox state of a running process (use `--operation` to test a specific op) |
| `sb graph export <KC>` | Build the cross-profile graph and serialize it for repeated queries |
| `sb graph load <FILE>` | Summarize a previously exported graph |
| `sb graph stats <KC>` | Print profile/operation counts and size statistics |
| `sb query <subcmd>` | Capability queries — see [below](#capability-queries) |

## Quick Workflow

```bash
# 1. List profiles
ipsw sb list kernelcache.release.iPhone18,1

# 2. Decompile one to SBPL (the human-readable source format)
ipsw sb dec kernelcache.release.iPhone18,1 com.apple.WebKit.WebContent -O WebContent.sb

# 3. Build the graph once for fast capability queries
ipsw sb graph export kernelcache.release.iPhone18,1 -O graph.json
```

## Decompilation

```bash
# All profiles
ipsw sb dec kernelcache.release.iPhone18,1

# Single profile
ipsw sb dec kernelcache.release.iPhone18,1 com.apple.WebKit.WebContent

# As flat assembly (closer to bytecode)
ipsw sb dec kernelcache.release.iPhone18,1 --format sbasm

# As structured JSON (array of profile objects with SBPL strings)
ipsw sb dec kernelcache.release.iPhone18,1 --format json

# From a pre-extracted profile blob (no kernelcache; specify Darwin version)
ipsw sb dec --type profile -i sandbox_profile.bin -o operations.txt --darwin-version 25.0.0

# Heavy profile (e.g., CommCenter) — disable node budget
ipsw sb dec kernelcache.release.iPhone18,1 com.apple.CommCenter --full-graph
```

## Operation Diff (track sandbox surface changes)

```bash
ipsw sb opts --diff kernelcache.release.iPhone17,1 kernelcache.release.iPhone18,1
```

Output shows added and removed sandbox operations between the two kernels — a fast way to spot new attack surface or hardening between releases.

## Capability Queries

The query commands answer "which profiles have permission X?" Each query runs against a graph; build once with `sb graph export`, then query many times.

```bash
# Build graph (slow once, fast forever after)
ipsw sb graph export kernelcache.release.iPhone18,1 -O graph.json
```

| Query | Question Answered |
|-------|-------------------|
| `sb query iokit-open <CLASS>` | Which profiles can open this IOKit user client? |
| `sb query path-read <PATH>` | Which profiles can read this filesystem path? |
| `sb query path-write <PATH>` | Which profiles can write to this path? |
| `sb query syscall <NAME\|NUM>` | Which profiles can call this syscall? |
| `sb query mach-lookup <SVC>` | Which profiles can look up this mach service? |
| `sb query mach-register <SVC>` | Which profiles can register this mach service? |
| `sb query sysctl <KEY>` | Which profiles can read/write this sysctl? |
| `sb query preference <DOMAIN>` | Which profiles can read/write this preference domain? |
| `sb query notification <NAME>` | Which profiles can post this notification? |
| `sb query cypher <EXPR>` | Run a constrained graph query (advanced) |

### Examples

```bash
# Find every profile that can open IOSurfaceRootUserClient
ipsw sb query iokit-open IOSurfaceRootUserClient --graph graph.json

# Find profiles that can write to /private/var/mobile/tmp
ipsw sb query path-write /private/var/mobile/tmp --graph graph.json

# Find profiles that can call mmap (by name or syscall number)
ipsw sb query syscall mmap --graph graph.json
ipsw sb query syscall 197 --graph graph.json

# JSON output → jq pipeline (e.g., only "allow" decisions)
ipsw sb query iokit-open IOSurfaceRootUserClient --graph graph.json -O json \
  | jq -r '.matches[] | select(.decision=="allow") | .profile' | sort -u

# Show guard conditions per match
ipsw sb query path-write /var/mobile/foo --graph graph.json -O json \
  | jq -r '.matches[] | "\(.profile): \(.guard_string)"'
```

### Skipping the graph (one-off queries)

```bash
# Build the graph in-memory and run one query (~40s per call)
ipsw sb query sysctl kern.osversion kernelcache.release.iPhone18,1
```

Use this only for occasional lookups. For interactive analysis, always export the graph first.

## Profile Compilation & Live Checks

```bash
# Compile a .sb source file to a binary profile blob
ipsw sb cmpl my_profile.sb -o ./

# Check sandbox state of a running process (macOS only, requires entitlements)
ipsw sb check 1234
ipsw sb check 1234 --operation file-read-data
```

## Tips

- **Always export the graph first.** Building it costs ~40s; querying a saved graph is sub-second.
- **Profile names are bundle-identifier-style.** Use `sb list` to discover them; pass them verbatim to `sb dec` and `sb query` filters.
- **`--type protobox`** targets the modern protobox collection on recent kernels; default is `collection`.
- **Pre-extracted blobs** (`sb dump` output) work as `-i` input to other `sb` commands, useful when you want to skip kernelcache parsing on every call.
