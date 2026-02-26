#!/usr/bin/env bash
set -euo pipefail

project_root="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
output_file="$project_root/dist/high_unified.txt"
source_dir="$project_root/sources"
mode="${1:-build}"

if [[ "$mode" != "build" && "$mode" != "--check" ]]; then
  echo "Usage: $0 [--check]" >&2
  exit 1
fi

source_files=()
while IFS= read -r file; do
  source_files+=("$file")
done < <(find "$source_dir" -maxdepth 1 -type f -name 'high_*.txt' | sort)

if [[ ${#source_files[@]} -eq 0 ]]; then
  echo "No source files matched: $source_dir/high_*.txt" >&2
  exit 1
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

cat "${source_files[@]}" \
  | sed -e 's/\r$//' -e '/^[[:space:]]*$/d' \
  | sort -u > "$tmp_file"

mkdir -p "$(dirname "$output_file")"

if [[ "$mode" == "--check" ]]; then
  if [[ ! -f "$output_file" ]]; then
    echo "Missing generated file: $output_file" >&2
    exit 1
  fi

  if cmp -s "$tmp_file" "$output_file"; then
    echo "high_unified.txt is up-to-date"
    exit 0
  fi

  echo "high_unified.txt is out-of-date, run scripts/build_high_unified.sh" >&2
  exit 1
fi

mv "$tmp_file" "$output_file"
trap - EXIT

echo "Generated: $output_file"
