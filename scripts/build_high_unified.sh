#!/usr/bin/env bash
set -euo pipefail

project_root="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
output_file="$project_root/dist/final_valuable_domains.txt"
source_dir="$project_root/sources"

mode="build"
levels_input="${LEVELS:-}"
categories_input="${CATEGORIES:-}"
default_categories_input="platforms,engineering,ai,community,content,services"

levels_arg_set=0
categories_arg_set=0

usage() {
  cat <<'USAGE'
Usage: scripts/build_high_unified.sh [build|--check] [--levels <levels> | --categories <categories>]

Options:
  --check                 Check whether output file is up-to-date
  --levels <levels>       Comma-separated levels: must,strong,optional,avoid
                          Use "all" to include all levels
  --categories <list>     Comma-separated categories, e.g. ai,community

Defaults:
  selector: --categories platforms,engineering,ai,community,content,services
USAGE
}

is_valid_level() {
  case "$1" in
    must|strong|optional|avoid)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_item() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    build)
      mode="build"
      shift
      ;;
    --check)
      mode="--check"
      shift
      ;;
    --levels)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --levels" >&2
        usage >&2
        exit 1
      fi
      levels_input="$2"
      levels_arg_set=1
      shift 2
      ;;
    --categories)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --categories" >&2
        usage >&2
        exit 1
      fi
      categories_input="$2"
      categories_arg_set=1
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ $levels_arg_set -eq 1 && $categories_arg_set -eq 1 ]]; then
  echo "--levels and --categories are mutually exclusive" >&2
  exit 1
fi

selector_mode="levels"
if [[ $categories_arg_set -eq 1 ]]; then
  selector_mode="categories"
elif [[ $levels_arg_set -eq 1 ]]; then
  selector_mode="levels"
elif [[ -n "$categories_input" ]]; then
  selector_mode="categories"
elif [[ -n "$levels_input" ]]; then
  selector_mode="levels"
else
  selector_mode="categories"
  categories_input="$default_categories_input"
fi

source_files=()

if [[ "$selector_mode" == "levels" ]]; then
  selected_levels=()

  if [[ "$levels_input" == "all" ]]; then
    selected_levels=(must strong optional avoid)
  else
    IFS=',' read -r -a raw_levels <<< "$levels_input"

    for raw in "${raw_levels[@]}"; do
      level="${raw//[[:space:]]/}"
      if [[ -z "$level" ]]; then
        continue
      fi

      if ! is_valid_level "$level"; then
        echo "Unknown level: $level" >&2
        echo "Valid levels: must,strong,optional,avoid,all" >&2
        exit 1
      fi

      if [[ ${#selected_levels[@]} -eq 0 ]]; then
        selected_levels+=("$level")
      elif ! has_item "$level" "${selected_levels[@]}"; then
        selected_levels+=("$level")
      fi
    done
  fi

  if [[ ${#selected_levels[@]} -eq 0 ]]; then
    echo "No levels selected. Use --levels <must,strong,...>" >&2
    exit 1
  fi

  for level in "${selected_levels[@]}"; do
    while IFS= read -r file; do
      source_files+=("$file")
    done < <(find "$source_dir" -maxdepth 1 -type f -name "${level}_*.txt" | sort)
  done

  rebuild_hint="scripts/build_high_unified.sh --levels \"$levels_input\""
else
  if [[ -z "$categories_input" ]]; then
    echo "No categories selected. Use --categories <ai,community,...>" >&2
    exit 1
  fi

  selected_categories=()
  IFS=',' read -r -a raw_categories <<< "$categories_input"

  for raw in "${raw_categories[@]}"; do
    category="${raw//[[:space:]]/}"
    if [[ -z "$category" ]]; then
      continue
    fi

    case "$category" in
      must_*|strong_*|optional_*|avoid_*)
        category="${category#*_}"
        ;;
    esac

    if [[ ! "$category" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
      echo "Invalid category: $category" >&2
      exit 1
    fi

    if [[ ${#selected_categories[@]} -eq 0 ]]; then
      selected_categories+=("$category")
    elif ! has_item "$category" "${selected_categories[@]}"; then
      selected_categories+=("$category")
    fi
  done

  if [[ ${#selected_categories[@]} -eq 0 ]]; then
    echo "No categories selected. Use --categories <ai,community,...>" >&2
    exit 1
  fi

  for category in "${selected_categories[@]}"; do
    matched_files=()
    while IFS= read -r file; do
      matched_files+=("$file")
    done < <(find "$source_dir" -maxdepth 1 -type f -name "*_${category}.txt" | sort)

    if [[ ${#matched_files[@]} -eq 0 ]]; then
      echo "Unknown category: $category" >&2
      exit 1
    fi

    for file in "${matched_files[@]}"; do
      if [[ ${#source_files[@]} -eq 0 ]]; then
        source_files+=("$file")
      elif ! has_item "$file" "${source_files[@]}"; then
        source_files+=("$file")
      fi
    done
  done

  rebuild_hint="scripts/build_high_unified.sh --categories \"$categories_input\""
fi

if [[ ${#source_files[@]} -eq 0 ]]; then
  echo "No source files matched selector in: $source_dir" >&2
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
    echo "final_valuable_domains.txt is up-to-date"
    exit 0
  fi

  echo "final_valuable_domains.txt is out-of-date, run $rebuild_hint" >&2
  exit 1
fi

mv "$tmp_file" "$output_file"
trap - EXIT

echo "Generated: $output_file"
