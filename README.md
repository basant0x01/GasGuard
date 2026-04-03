# Gas Guard Advanced

A fast, grep-first Solidity gas review helper for spotting common gas optimization candidates in smart contracts.

`gasGuard.sh` is designed for quick audits during development, review, or CI. It scans Solidity files with tighter pattern matching than the original helper scripts, strips comments before analysis, reduces noisy matches, and prints actionable recommendations with rule IDs, severity, and suggested fixes.

> This tool is **pattern-based**, not AST-based. Treat findings as high-confidence review candidates, not guaranteed issues.

---

## Features

- Single-file scanner with no fragile `source` chain
- Scan one file, many files, or an entire directory recursively
- Comment stripping before analysis to reduce false positives
- Human-readable output with:
  - rule ID
  - severity
  - line number
  - matched code
  - recommendation
  - suggested fix
- Optional source context around each finding
- Optional JSON output for scripting and CI
- Non-zero exit code when findings are detected
- Better regex targeting for Solidity gas-review patterns

---

## Supported Rules

| Rule ID | Severity | Check |
|---|---:|---|
| `G001` | Low | Default initialization in loop counters (`uint256 i = 0`) |
| `G002` | Medium | Array `.length` used directly in loop conditions |
| `G003` | Low | `> 0` or `>= 1` comparisons that may be cheaper as `!= 0` |
| `G004` | Medium | Revert strings / `require(..., "...")` instead of custom errors |
| `G005` | Low | Postfix increment/decrement (`i++`, `i--`) |
| `G006` | Info | Multiplication/division by powers of two that may be replaced with shifts |
| `G007` | Medium | `external` functions using `memory` for reference parameters |
| `G008` | Info | Zero-address checks worth reviewing for cheaper error handling patterns |

---

## Installation

### Requirements

The script uses common Unix tools:

- `bash`
- `grep`
- `awk`
- `sed`
- `perl`
- `find`
- `sort`
- `uniq`
- `python3` (used for JSON string escaping)

### Make it executable

```bash
chmod +x gasGuard.sh
```

---

## Usage

### Scan a single Solidity file

```bash
./gasGuard.sh -i contracts/MyContract.sol
```

### Scan multiple Solidity files

```bash
./gasGuard.sh -mi contracts/A.sol contracts/B.sol contracts/C.sol
```

### Scan a directory recursively

```bash
./gasGuard.sh -d ./contracts
```

### Show source context around matches

```bash
./gasGuard.sh -d ./contracts --context 2
```

### Emit JSON output

```bash
./gasGuard.sh -d ./contracts --json
```

### Disable ANSI colors

```bash
./gasGuard.sh -d ./contracts --no-color
```

### Quiet mode

```bash
./gasGuard.sh -d ./contracts --quiet
```

---

## Command-Line Options

| Option | Description |
|---|---|
| `-i`, `--input <file>` | Scan a single Solidity file |
| `-mi`, `--multi-input <files>` | Scan multiple Solidity files |
| `-d`, `--dir <directory>` | Recursively scan a directory for `*.sol` files |
| `-c`, `--context <n>` | Show `n` lines of source context around each finding |
| `--json` | Output findings as JSON |
| `--no-color` | Disable ANSI colors |
| `-q`, `--quiet` | Only print findings and summary |
| `-h`, `--help` | Show help text |

---

## Example Output

```text
Gas Guard Advanced v2.0.0
Pattern-based Solidity gas review with improved matching and fewer false positives.

FILE contracts/Vault.sol
  [MEDIUM] G004 - String revert / require message
    line : 41
    code : require(msg.sender == owner, "unauthorized");
    why  : Custom errors are cheaper than revert strings in deployment bytecode and runtime revert data.
    fix  : error Unauthorized(); if (msg.sender != owner) revert Unauthorized();

  [LOW] G005 - Postfix increment/decrement
    line : 78
    code : for (uint256 i; i < len; i++) {
    why  : Use prefix ++i/--i when the expression value is not needed. On Solidity >=0.8, trusted loop counters may also benefit from unchecked increments.
    fix  : for (uint256 i; i < n; ++i) { ... }

Summary
  Files scanned : 1
  Findings      : 2
  Rules hit     :
    - G004: 1
    - G005: 1
```

---

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Scan completed and no findings were detected |
| `1` | Invalid usage or runtime error |
| `2` | Scan completed and one or more findings were detected |

This makes the script useful in CI pipelines where you want the job to fail when review candidates are found.

---

## JSON Output

When `--json` is used, the tool emits an array of finding objects.

Example:

```json
[
  {
    "file": "contracts/Vault.sol",
    "line": "41",
    "rule": "G004",
    "severity": "MEDIUM",
    "title": "String revert / require message",
    "code": "require(msg.sender == owner, \"unauthorized\");",
    "recommendation": "Custom errors are cheaper than revert strings in deployment bytecode and runtime revert data.",
    "fix": "error Unauthorized(); if (msg.sender != owner) revert Unauthorized();"
  }
]
```

---

## Recommended Workflow

Use Gas Guard as a fast first-pass review step:

1. Run it against a contract or codebase.
2. Review each hit manually.
3. Confirm the optimization is valid for the specific code path.
4. Benchmark hot paths before making readability trade-offs.
5. Use an AST-based analyzer or manual review for final confirmation.

---

## Limitations

Because this tool is regex-based:

- it does **not** fully parse Solidity syntax
- it may miss some valid optimization opportunities
- it may still report some false positives in edge cases
- it should not replace manual review, profiling, or compiler-aware tooling

It is best used as a lightweight gas-review assistant, not a final authority.

---

## File Layout

```text
gasGuard.sh
README.md
```

---

## License

Add your preferred license here, for example MIT.

---

## Author

Created for your advanced `gasGuard.sh` workflow and README refresh.
