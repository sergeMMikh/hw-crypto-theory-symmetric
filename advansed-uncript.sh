#!/usr/bin/env bash
set -Eeuo pipefail

dir="/home/smm/sib/SecLists/Passwords/Common-Credentials"
hash="5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab"
outfile="cracked.txt"

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

# length of hex string (number of hex chars)
hexlen=${#hash}

uncript(){
    local mode="$1"
    hashcat -m "$mode" "$hash" "$dir"/* \
      --potfile-disable \
      --outfile="$outfile" --outfile-autohex-disable \
      --quiet >/dev/null 2>&1
    return $?
}

needs_len_ok() {
  local mode="$1"
  case "$mode" in
    900|0)      [[ $hexlen -eq 32  ]];;   # MD4/MD5 (32 hex chars)
    100)        [[ $hexlen -eq 40  ]];;   # SHA1 (40)
    1300)       [[ $hexlen -eq 56  ]];;   # SHA224 (56)
    1400|6900|11700) [[ $hexlen -eq 64  ]];;  # SHA256 / GOST94 / Streebog-256 (64)
    10800)      [[ $hexlen -eq 96  ]];;   # SHA384 (96)
    1700|11800) [[ $hexlen -eq 128 ]];;   # SHA512 / Streebog-512 (128)
    *)          return 1;;
  esac
}

: > "$outfile"

 for path in "$dir"/*; do
    [ -f "$path" ] || continue
    case "$path" in
      *.txt|*.lst) ;;           # работаем только с текстовыми словарями
      *) echo ">> Пропуск: $(basename "$path")"; continue ;;
    esac

    echo ">>> Словарь: $(basename "$path")"
    
    for m in "${modes[@]}"; do

    echo "[*] Try mode $m"
    if ! needs_len_ok "$m"; then
        echo "[~] Skip mode $m (incompatible length: $hexlen)"
        continue
    fi

    if uncript "$m"; then
        echo "[+] FOUND in mode $m:"
        tail -n 1 "$outfile"
        exit 0
    else
        rc=$?
        if [[ $rc -eq 1 ]]; then
        echo "[-] Not found (rc=$rc)"
        else
        echo "[!] Hashcat error/abort in mode $m (rc=$rc)"
        fi
    fi
    done
done

echo "[x] No match in provided modes/wordlists"
exit 1
