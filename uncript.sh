#!/bin/bash

dir="/home/smm/hw-linux/seclists/Passwords/Common-Credentials"
hash=$1
outfile="cracked.txt"

hash="${1:-}"
[[ -n "$hash" ]] || { echo "Usage: $0 '<hash>'" >&2; exit 2; }

modes=(
  "0"
"100"
"1400"
"1700"
"900"
"500"
"7400"
"1800"
"1500"
"3200"
'8900'
"12400"
"1000"
"1100"
"5500"
'5600'
"400"
'1100'
'7900'
"11000"
'2612'
"1731"
"2500"
"11400"
"200"
"300"
"12000"
"13000"
"13100"
"9600"
"10100"
"10300"
"11600"
"12500"
"13000"
"2400"
"2410"
"1600"
"7800"
"8300"
"8400"
"1300"
"10800"
"17300"
"17400"   
)

 : > "$outfile"
for f in "$dir"/*; do
  [[ -f "$f" ]] || continue

  for m in "${modes[@]}"; do
  
    echo "Try mode $m in file $f"
    [[ -f "$f" ]] || continue

    out=$(hashcat -m "$m" "$hash" --show 2>/dev/null)

    rc=$?

    case $rc in
      0)
        if [[ -n "$out" ]]; then
          echo "[+] FOUND" >> "$outfile"
          echo "$out" >> "$outfile"
        fi
        ;;
      1) ;;                 
      255) echo "[-] length is wrong";;
      *) echo "[!] error rc=$rc" >&2 ;;
    esac
  done
done

exit 1

