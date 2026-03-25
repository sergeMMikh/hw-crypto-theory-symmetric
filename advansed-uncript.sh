#!/usr/bin/env bash
set -Eeuo pipefail

dir="/home/smm/sib/SecLists/Passwords/Common-Credentials"
default_hash="b896c0996c75a84f378c6ec0af924a800c0b7fcd0ee860b8fb8d7b45f7e9fd8d910604d22b6b9000965a0047c5009ee967a75bf21690412376da9f7bc48a8402"
hash="${1:-$default_hash}"
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

if ! command -v hashcat >/dev/null 2>&1; then
  echo "[!] hashcat not found in PATH"
  exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${XDG_DATA_HOME:-}" ]]; then
  hc_data_dir="$XDG_DATA_HOME"
else
  hc_data_dir="$script_dir/.xdg-data"
fi

if ! mkdir -p "$hc_data_dir/hashcat/sessions" 2>/dev/null; then
  hc_data_dir="/tmp/hashcat-xdg-${USER:-user}"
  mkdir -p "$hc_data_dir/hashcat/sessions"
fi
export XDG_DATA_HOME="$hc_data_dir"

uncript(){
  local mode="$1"
  local wordlist="$2"
  local hc_log
  local rc
  hc_log="$(mktemp)"

  hashcat -a 0 -m "$mode" "$hash" "$wordlist" \
    -O ${rule:+-r "$rule"} \
    --potfile-disable \
    --outfile="$outfile" --outfile-autohex-disable \
    --quiet > /dev/null 2>"$hc_log"
  rc=$?

  if grep -q -E "^${hash}:" "$outfile"; then
    rm -f "$hc_log"
    return 0
  fi

  if [[ $rc -ne 0 && $rc -ne 1 ]]; then
    echo "[!] hashcat error in mode $mode on $(basename "$wordlist") (rc=$rc)"
    sed -n '1,4p' "$hc_log"
  fi

  rm -f "$hc_log"
  return 1
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
