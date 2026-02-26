#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/scripts"
cp "$repo_root/scripts/build_high_unified.sh" "$workdir/scripts/build_high_unified.sh"
chmod +x "$workdir/scripts/build_high_unified.sh"
mkdir -p "$workdir/sources"

cat > "$workdir/sources/high_alpha.txt" <<'SRC'
.c.example
.a.example

SRC

cat > "$workdir/sources/high_beta.txt" <<'SRC'
.b.example
.c.example
SRC

cat > "$workdir/sources/high_gamma.txt" <<'SRC'
.a.example
SRC

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh"

cat > "$workdir/expected.txt" <<'EXP'
.a.example
.b.example
.c.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected.txt"
