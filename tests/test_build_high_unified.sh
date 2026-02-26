#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/scripts"
cp "$repo_root/scripts/build_high_unified.sh" "$workdir/scripts/build_high_unified.sh"
chmod +x "$workdir/scripts/build_high_unified.sh"
mkdir -p "$workdir/sources"

cat > "$workdir/sources/must_platforms.txt" <<'SRC'
.c.example
.a.example

SRC

cat > "$workdir/sources/strong_ai.txt" <<'SRC'
.b.example
.c.example
SRC

cat > "$workdir/sources/strong_community.txt" <<'SRC'
.m.example
SRC

cat > "$workdir/sources/strong_content.txt" <<'SRC'
.n.example
SRC

cat > "$workdir/sources/strong_services.txt" <<'SRC'
.p.example
SRC

cat > "$workdir/sources/optional_crypto.txt" <<'SRC'
.d.example
SRC

cat > "$workdir/sources/optional_engineering.txt" <<'SRC'
.g.example
SRC

cat > "$workdir/sources/optional_adult.txt" <<'SRC'
.h.example
SRC

cat > "$workdir/sources/avoid_others.txt" <<'SRC'
.e.example
SRC

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh"

cat > "$workdir/expected_default.txt" <<'EXP'
.a.example
.b.example
.c.example
.g.example
.m.example
.n.example
.p.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected_default.txt"

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --levels must,strong,optional

cat > "$workdir/expected_optional.txt" <<'EXP'
.a.example
.b.example
.c.example
.d.example
.g.example
.h.example
.m.example
.n.example
.p.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected_optional.txt"
PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --check --levels must,strong,optional

echo ".f.example" >> "$workdir/sources/optional_crypto.txt"

if PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --check --levels must,strong,optional; then
  echo "expected --check to fail after source change" >&2
  exit 1
fi

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --levels must,strong,optional

cat > "$workdir/expected_optional_updated.txt" <<'EXP'
.a.example
.b.example
.c.example
.d.example
.f.example
.g.example
.h.example
.m.example
.n.example
.p.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected_optional_updated.txt"

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --categories ai,community

cat > "$workdir/expected_categories_core.txt" <<'EXP'
.b.example
.c.example
.m.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected_categories_core.txt"
PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --check --categories ai,community

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --categories platforms,crypto

cat > "$workdir/expected_categories_mix.txt" <<'EXP'
.a.example
.c.example
.d.example
.f.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected_categories_mix.txt"

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --levels all

cat > "$workdir/expected_all.txt" <<'EXP'
.a.example
.b.example
.c.example
.d.example
.e.example
.f.example
.g.example
.h.example
.m.example
.n.example
.p.example
EXP

cmp -s "$workdir/dist/final_valuable_domains.txt" "$workdir/expected_all.txt"

PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --check --levels all

if PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --levels must,unknown >/dev/null 2>&1; then
  echo "expected invalid level to fail" >&2
  exit 1
fi

if PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --categories ai,unknown >/dev/null 2>&1; then
  echo "expected unknown category to fail" >&2
  exit 1
fi

if PROJECT_ROOT="$workdir" "$workdir/scripts/build_high_unified.sh" --levels must,strong --categories ai >/dev/null 2>&1; then
  echo "expected mixed selectors to fail" >&2
  exit 1
fi
