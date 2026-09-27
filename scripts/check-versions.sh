#!/usr/bin/env bash
# Verify every manifest carries the same release version and CHANGELOG.md documents it.
# With a base ref argument (e.g. origin/main), also require a version bump when ipsw/ changed.
set -euo pipefail

cd "$(dirname "$0")/.."

skill_version="$(sed -n 's/^  version: "\(.*\)"$/\1/p' ipsw/SKILL.md | head -n 1)"
declare -A versions=(
	["ipsw/SKILL.md metadata.version"]="$skill_version"
	[".claude-plugin/plugin.json"]="$(jq -r .version .claude-plugin/plugin.json)"
	[".claude-plugin/marketplace.json metadata.version"]="$(jq -r .metadata.version .claude-plugin/marketplace.json)"
	[".codex-plugin/plugin.json"]="$(jq -r .version .codex-plugin/plugin.json)"
	["package.json"]="$(jq -r .version package.json)"
)

status=0
for source in "${!versions[@]}"; do
	if [[ "${versions[$source]}" != "$skill_version" ]]; then
		echo "version mismatch: $source has '${versions[$source]}', ipsw/SKILL.md has '$skill_version'" >&2
		status=1
	fi
done

if ! grep -q "^## \[$skill_version\]" CHANGELOG.md; then
	echo "CHANGELOG.md has no '## [$skill_version]' entry" >&2
	status=1
fi

if [[ $# -gt 0 ]]; then
	base="$1"
	if ! git diff --quiet "$base" -- ipsw/; then
		base_version="$(git show "$base:ipsw/SKILL.md" | sed -n 's/^  version: "\(.*\)"$/\1/p' | head -n 1)"
		if [[ "$base_version" == "$skill_version" ]]; then
			echo "ipsw/ changed since $base but the version is still $skill_version; bump it in every manifest" >&2
			status=1
		fi
	fi
fi

if [[ $status -eq 0 ]]; then
	echo "all manifests at version $skill_version"
fi
exit "$status"
