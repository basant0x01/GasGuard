#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="2.0.0"
SCRIPT_NAME="$(basename "$0")"
DEFAULT_CONTEXT=0
NO_COLOR=0
QUIET=0
OUTPUT_MODE="text"
RECURSIVE=0
CONTEXT_LINES="$DEFAULT_CONTEXT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

FILES=()
RESULTS=()
DELIM=$'\x1f'
declare -A SEEN_MATCHES=()
declare -A RULE_COUNTS=()
TOTAL_FINDINGS=0
SCANNED_FILES=0

usage() {
  cat <<USAGE
Gas Guard Advanced v${VERSION}
A grep-first Solidity gas review helper with safer, narrower pattern matching.

Usage:
  ${SCRIPT_NAME} -i contract.sol
  ${SCRIPT_NAME} -mi contracts/A.sol contracts/B.sol
  ${SCRIPT_NAME} -d ./contracts

Options:
  -i,  --input <file>         Scan a single Solidity file
  -mi, --multi-input <files>  Scan multiple Solidity files
  -d,  --dir <directory>      Recursively scan a directory for *.sol
  -c,  --context <n>          Show N lines of source context around each finding
       --json                 Emit JSON instead of human-readable text
       --no-color             Disable ANSI colors
  -q,  --quiet                Only print findings and summary
  -h,  --help                 Show this help message

Notes:
  - This is still pattern-based. It is much more precise than the original scripts,
    but it is not a full Solidity parser.
  - Treat findings as review candidates, not guaranteed vulnerabilities.
USAGE
}

color() {
  local c="$1"
  shift
  if [[ "$NO_COLOR" -eq 1 ]]; then
    printf '%s' "$*"
  else
    printf '%b%s%b' "$c" "$*" "$NC"
  fi
}

trim() {
  local s="$1"
  s="${s#${s%%[![:space:]]*}}"
  s="${s%${s##*[![:space:]]}}"
  printf '%s' "$s"
}

json_escape() {
  python3 - <<'PY' "$1"
import json,sys
print(json.dumps(sys.argv[1]))
PY
}

require_tools() {
  local missing=()
  local tools=(grep awk sed perl find sort uniq)
  for t in "${tools[@]}"; do
    command -v "$t" >/dev/null 2>&1 || missing+=("$t")
  done
  if (( ${#missing[@]} > 0 )); then
    echo "Missing required tools: ${missing[*]}" >&2
    exit 1
  fi
}

add_file() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "[-] File not found: $f" >&2
    return 1
  fi
  if [[ "$f" != *.sol ]]; then
    return 0
  fi
  FILES+=("$f")
}

add_dir() {
  local d="$1"
  if [[ ! -d "$d" ]]; then
    echo "[-] Directory not found: $d" >&2
    return 1
  fi
  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "$d" -type f -name '*.sol' -print0 | sort -z)
}

strip_comments_preserve_lines() {
  local file="$1"
  perl -0777 -pe '
    s{ /\* .*? \*/ }{
      my $m = $&;
      my $n = ($m =~ tr/\n//);
      "\n" x $n;
    }gsex;
    s{//[^\n\r]*}{}g;
  ' "$file"
}

numbered_clean_lines() {
  local file="$1"
  strip_comments_preserve_lines "$file" | awk '{ printf "%d\t%s\n", NR, $0 }'
}

generate_statements() {
  local file="$1"
  strip_comments_preserve_lines "$file" | awk '
    function flush() {
      if (buf != "") {
        gsub(/[[:space:]]+/, " ", buf)
        sub(/^ /, "", buf)
        sub(/ $/, "", buf)
        if (buf != "") print start "\t" buf
      }
      buf = ""
      start = 0
    }
    {
      line = $0
      gsub(/\r/, "", line)
      if (line ~ /^[[:space:]]*$/) next
      if (start == 0) start = NR
      buf = buf " " line
      if (line ~ /[;{}][[:space:]]*$/ || line ~ /[;{}]/) flush()
    }
    END { flush() }
  '
}

source_line() {
  local file="$1" line="$2"
  sed -n "${line}p" "$file" | sed 's/[[:space:]]\+$//'
}

context_block() {
  local file="$1" line="$2" ctx="$3"
  local start end
  start=$(( line - ctx ))
  end=$(( line + ctx ))
  (( start < 1 )) && start=1
  awk -v start="$start" -v end="$end" -v hit="$line" '
    NR < start || NR > end { next }
    {
      marker = (NR == hit ? ">" : " ")
      printf "%s %5d | %s\n", marker, NR, $0
    }
  ' "$file"
}

emit_match() {
  local file="$1" line="$2" rule_id="$3" severity="$4" title="$5" recommendation="$6" example="$7" code="$8"
  local key="${file}|${line}|${rule_id}|${code}"
  if [[ -n "${SEEN_MATCHES[$key]:-}" ]]; then
    return 0
  fi
  SEEN_MATCHES[$key]=1
  RESULTS+=("${file}${DELIM}${line}${DELIM}${rule_id}${DELIM}${severity}${DELIM}${title}${DELIM}${recommendation}${DELIM}${example}${DELIM}${code}")
  RULE_COUNTS["$rule_id"]=$(( ${RULE_COUNTS["$rule_id"]:-0} + 1 ))
  TOTAL_FINDINGS=$(( TOTAL_FINDINGS + 1 ))
}

scan_lines_for_patterns() {
  local file="$1"
  while IFS=$'\t' read -r line code; do
    code="$(trim "$code")"
    [[ -z "$code" ]] && continue

    if grep -Eq '([[:alnum:]_\]\)]+)[[:space:]]*(\+\+|--)' <<< "$code"; then
      emit_match "$file" "$line" "G005" "LOW" \
        "Postfix increment/decrement" \
        "Use prefix ++i/--i when the expression value is not needed. On Solidity >=0.8, trusted loop counters may also benefit from unchecked increments." \
        "for (uint256 i; i < n; ++i) { ... }" \
        "$code"
    fi

    if grep -Eq '[[:space:]]>[[:space:]]*0($|[^0-9])|>=[[:space:]]*1($|[^0-9])' <<< "$code"; then
      emit_match "$file" "$line" "G003" "LOW" \
        "Comparison against zero" \
        "For unsigned values, x != 0 is usually cheaper than x > 0. Review before changing signed values or places where readability matters more." \
        "if (amount != 0) { ... }" \
        "$code"
    fi

    if grep -Eq '(\*|/)[[:space:]]*(2|4|8|16|32|64|128|256|512|1024|2048|4096|8192|16384|32768|65536)($|[^0-9])|(^|[^0-9])(2|4|8|16|32|64|128|256|512|1024|2048|4096|8192|16384|32768|65536)[[:space:]]*\*[[:space:]]*[[:alnum:]_\(]' <<< "$code"; then
      emit_match "$file" "$line" "G006" "INFO" \
        "Multiply/divide by power of two" \
        "Bit shifting can be cheaper than multiplying or dividing by powers of two, but only change this when the arithmetic semantics stay identical, especially for signed values and rounding." \
        "x << 2  or  x >> 1" \
        "$code"
    fi

    if grep -Eq '(==|!=)[[:space:]]*address[[:space:]]*\([[:space:]]*0[[:space:]]*\)|address[[:space:]]*\([[:space:]]*0[[:space:]]*\)[[:space:]]*(==|!=)' <<< "$code"; then
      emit_match "$file" "$line" "G008" "INFO" \
        "Zero-address check" \
        "Prefer a custom error for zero-address validation. Low-level assembly is only worth considering in extremely hot paths after measuring gas and readability trade-offs." \
        "error ZeroAddress(); if (account == address(0)) revert ZeroAddress();" \
        "$code"
    fi
  done < <(numbered_clean_lines "$file")
}

scan_statements_for_patterns() {
  local file="$1"
  while IFS=$'\t' read -r line stmt; do
    stmt="$(trim "$stmt")"
    [[ -z "$stmt" ]] && continue

    if grep -Eq '(^|[[:space:]])for[[:space:]]*\([[:space:]]*(uint|uint8|uint16|uint32|uint64|uint128|uint256|int|int8|int16|int32|int64|int128|int256)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=[[:space:]]*0[[:space:]]*;' <<< "$stmt"; then
      emit_match "$file" "$line" "G001" "LOW" \
        "Default initialization in loop counter" \
        "Numeric loop counters are zero-initialized by default. You can usually omit '= 0' in the loop initializer." \
        "for (uint256 i; i < n; ++i) { ... }" \
        "$stmt"
    fi

    if grep -Eq '(^|[[:space:]])for[[:space:]]*\(.*\.length.*\)' <<< "$stmt"; then
      emit_match "$file" "$line" "G002" "MEDIUM" \
        "Array length read inside loop condition" \
        "Cache array length outside the loop so the length is not re-read on every iteration." \
        "uint256 len = arr.length; for (uint256 i; i < len; ++i) { ... }" \
        "$stmt"
    fi

    if grep -Eq '([A-Za-z_][A-Za-z0-9_]*|\]|\))[[:space:]]*(\+\+|--)' <<< "$stmt"; then
      emit_match "$file" "$line" "G005" "LOW" \
        "Postfix increment/decrement" \
        "Use prefix ++i/--i when the expression value is not needed. On Solidity >=0.8, trusted loop counters may also benefit from unchecked increments." \
        "for (uint256 i; i < n; ++i) { ... }" \
        "$stmt"
    fi

    if grep -Eq '(^|[[:space:]])require[[:space:]]*\(.*,[[:space:]]*"[^"]+"[[:space:]]*\)|(^|[[:space:]])revert[[:space:]]*\([[:space:]]*"[^"]+"[[:space:]]*\)' <<< "$stmt"; then
      emit_match "$file" "$line" "G004" "MEDIUM" \
        "String revert / require message" \
        "Custom errors are cheaper than revert strings in deployment bytecode and runtime revert data." \
        "error Unauthorized(); if (msg.sender != owner) revert Unauthorized();" \
        "$stmt"
    fi

    if grep -Eq '(^|[[:space:]])function[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\([^)]*memory[^)]*\)[^{;]*external([[:space:]]|$)' <<< "$stmt"; then
      emit_match "$file" "$line" "G007" "MEDIUM" \
        "External function uses memory for reference params" \
        "For external functions, reference-type parameters such as string, bytes, arrays, and structs are often cheaper as calldata when they are read-only." \
        "function foo(string calldata name, uint256[] calldata amounts) external { ... }" \
        "$stmt"
    fi
  done < <(generate_statements "$file")
}

print_text_results() {
  local last_file=""
  for entry in "${RESULTS[@]}"; do
    IFS="$DELIM" read -r file line rule severity title recommendation example code <<< "$entry"
    if [[ "$file" != "$last_file" ]]; then
      [[ -n "$last_file" ]] && echo
      echo "$(color "$BLUE" "FILE") $(color "$BOLD" "$file")"
      last_file="$file"
    fi

    local sev_color="$YELLOW"
    [[ "$severity" == "MEDIUM" ]] && sev_color="$RED"
    [[ "$severity" == "INFO" ]] && sev_color="$BLUE"

    echo "  $(color "$sev_color" "[$severity]") $(color "$BOLD" "$rule") - $title"
    echo "    line : $line"
    echo "    code : $code"
    echo "    why  : $recommendation"
    echo "    fix  : $example"
    if (( CONTEXT_LINES > 0 )); then
      echo "    ctx  :"
      context_block "$file" "$line" "$CONTEXT_LINES" | sed 's/^/      /'
    fi
    echo
  done
}

print_json_results() {
  echo "["
  local first=1
  for entry in "${RESULTS[@]}"; do
    IFS="$DELIM" read -r file line rule severity title recommendation example code <<< "$entry"
    [[ $first -eq 0 ]] && echo ","
    first=0
    printf '  {"file":%s,"line":%s,"rule":%s,"severity":%s,"title":%s,"code":%s,"recommendation":%s,"fix":%s}' \
      "$(json_escape "$file")" \
      "$(json_escape "$line")" \
      "$(json_escape "$rule")" \
      "$(json_escape "$severity")" \
      "$(json_escape "$title")" \
      "$(json_escape "$code")" \
      "$(json_escape "$recommendation")" \
      "$(json_escape "$example")"
  done
  echo
  echo "]"
}

print_summary() {
  if [[ "$OUTPUT_MODE" == "json" ]]; then
    return 0
  fi
  echo "$(color "$BOLD" "Summary")"
  echo "  Files scanned : $SCANNED_FILES"
  echo "  Findings      : $TOTAL_FINDINGS"
  if (( TOTAL_FINDINGS > 0 )); then
    echo "  Rules hit     :"
    for rule in "$(printf '%s
' "${!RULE_COUNTS[@]}" | sort)"; do
      :
    done
    while IFS= read -r rule; do
      [[ -z "$rule" ]] && continue
      printf '    - %s: %s\n' "$rule" "${RULE_COUNTS[$rule]}"
    done < <(printf '%s
' "${!RULE_COUNTS[@]}" | sort)
  fi
}

parse_args() {
  [[ $# -eq 0 ]] && usage && exit 1
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input)
        [[ $# -lt 2 ]] && { echo "Missing value for $1" >&2; exit 1; }
        add_file "$2"
        shift 2
        ;;
      -mi|--multi-input)
        shift
        while [[ $# -gt 0 && "$1" != -* ]]; do
          add_file "$1"
          shift
        done
        ;;
      -d|--dir)
        [[ $# -lt 2 ]] && { echo "Missing value for $1" >&2; exit 1; }
        add_dir "$2"
        shift 2
        ;;
      -c|--context)
        [[ $# -lt 2 ]] && { echo "Missing value for $1" >&2; exit 1; }
        CONTEXT_LINES="$2"
        shift 2
        ;;
      --json)
        OUTPUT_MODE="json"
        shift
        ;;
      --no-color)
        NO_COLOR=1
        shift
        ;;
      -q|--quiet)
        QUIET=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
}

main() {
  require_tools
  parse_args "$@"

  if (( ${#FILES[@]} == 0 )); then
    echo "No Solidity files provided." >&2
    exit 1
  fi

  IFS=$'\n' read -r -d '' -a FILES < <(printf '%s\n' "${FILES[@]}" | awk '!seen[$0]++' && printf '\0')

  if [[ "$OUTPUT_MODE" == "text" && "$QUIET" -eq 0 ]]; then
    echo "$(color "$BLUE" "Gas Guard Advanced v${VERSION}")"
    echo "$(color "$DIM" "Pattern-based Solidity gas review with improved matching and fewer false positives.")"
    echo
  fi

  local file
  for file in "${FILES[@]}"; do
    [[ ! -f "$file" ]] && continue
    SCANNED_FILES=$(( SCANNED_FILES + 1 ))
    scan_statements_for_patterns "$file"
    scan_lines_for_patterns "$file"
  done

  if [[ "$OUTPUT_MODE" == "json" ]]; then
    print_json_results
  else
    if (( TOTAL_FINDINGS == 0 )); then
      echo "$(color "$GREEN" "No gas-review matches found.")"
    else
      print_text_results
    fi
    print_summary
  fi

  if (( TOTAL_FINDINGS > 0 )); then
    exit 2
  fi
}

main "$@"
