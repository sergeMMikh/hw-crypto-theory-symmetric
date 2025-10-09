#!/bin/bash

dir="/home/smm/sib/SecLists/Passwords/Common-Credentials"
hash="5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab"
outfile="cracked.txt"

modes=(
  "900"     
  "0"      
  "100"     
  "1300"   
  "1400"    
  "10800"  
  "1700"  
  "11700"   
  "11800"  
  "6900"   
)

: > "$outfile"

for m in "${modes[@]}"; do
  echo "[*] Try mode $m"
  
  hashcat -m "$m" "$hash" "$dir"/* \
    --potfile-disable \
    --outfile="$outfile" --outfile-autohex-disable \
    --quiet >/dev/null 2>&1
  rc=$?

  if [[ $rc -eq 0 ]]; then
    echo "[+] FOUND in mode $m:"
    tail -n 1 "$outfile"
    exit 0
  elif [[ $rc -eq 1 ]]; then
    echo "[-] Not found in mode $m"
  else
    echo "[!] Hashcat error/abort in mode $m (rc=$rc)"
  fi
done

echo "[x] No match in provided modes/wordlists"
exit 1