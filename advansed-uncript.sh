#!/usr/bin/env bash
set -Eeuo pipefail

dir="/home/smm/sib/SecLists/Passwords/Common-Credentials"
hash="5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab"
outfile="cracked.txt"
rule="/usr/share/hashcat/rules/best64.rule"

modes=(
  "900"     # MD4
  "0"       # MD5
  "100"     # SHA1
  "1300"    # SHA2-224
  "1400"    # SHA2-256
  "10800"   # SHA2-384
  "1700"    # SHA2-512
  "11700"   # Streebog-256
  "11800"   # Streebog-512
  "6900"    # GOST 34.11-94
)

hexlen=${#hash}

# ---------- traps ----------
CURRENT_MODE=""
CURRENT_WORDLIST=""

on_err() {
  local rc=$?
  local line=${1:-$LINENO}
  local cmd=${2:-$BASH_COMMAND}
  echo "[!] ERR rc=$rc at line $line"
  echo "    cmd: $cmd"
  echo "    ctx: mode=${CURRENT_MODE:-N/A} wordlist=$(basename "${CURRENT_WORDLIST:-N/A}" 2>/dev/null || echo N/A)"
}

on_int() {
  echo "[^C] Interrupted. Last ctx: mode=${CURRENT_MODE:-N/A} wordlist=$(basename "${CURRENT_WORDLIST:-N/A}" 2>/dev/null || echo N/A)"
  if grep -q -E "^${hash}:" "$outfile" 2>/dev/null; then
    echo "[=] Already cracked:"
    grep -E "^${hash}:" "$outfile" | tail -n1
    exit 0
  fi
  exit 130
}

trap 'on_err $LINENO "$BASH_COMMAND"' ERR
trap 'on_int' INT TERM

uncript(){
  local mode="$1"
  local wordlist="$2"

  hashcat -a 0 -m "$mode" "$hash" "$wordlist" \
    -O ${rule:+-r "$rule"} \
    --potfile-disable \
    --outfile="$outfile" --outfile-autohex-disable \
    --quiet >/dev/null 2>&1 || true

  grep -q -E "^${hash}:" "$outfile"
}

needs_len_ok() {
  local mode="$1"
  case "$mode" in
    900|0)                  [[ $hexlen -eq 32  ]];;   # MD4/MD5
    100)                    [[ $hexlen -eq 40  ]];;   # SHA1
    1300)                   [[ $hexlen -eq 56  ]];;   # SHA224
    1400|6900|11700)        [[ $hexlen -eq 64  ]];;   # SHA256/GOST94/Streebog-256
    10800)                  [[ $hexlen -eq 96  ]];;   # SHA384
    1700|11800)             [[ $hexlen -eq 128 ]];;   # SHA512/Streebog-512
    *)                      return 1;;
  esac
}

: > "$outfile"

for path in "$dir"/*; do
  [ -f "$path" ] || continue
  case "$path" in
    *.txt|*.lst) ;;
    *) echo ">> Пропуск: $(basename "$path")"; continue ;;
  esac

  echo ">>> Словарь: $(basename "$path")"

  for m in "${modes[@]}"; do
    echo "[*] Try mode $m"
    if ! needs_len_ok "$m"; then
      echo "[~] Skip mode $m (incompatible length: $hexlen)"
      continue
    fi

    # обновляем контекст для trap
    CURRENT_MODE="$m"
    CURRENT_WORDLIST="$path"

    if uncript "$m" "$path"; then
      echo "[+] FOUND in mode $m:"
      grep -E "^${hash}:" "$outfile" | tail -n1
      exit 0
    else
      echo "[-] Not found in mode $m"
    fi
  done
done

echo "[x] No match in provided modes/wordlists"
exit 1
