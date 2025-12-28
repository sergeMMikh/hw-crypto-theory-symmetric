#!/bin/bash

# sudo hashcat -m 6900 5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab /home/smm/hw-linux/seclists/Passwords/Common-Credentials/xato-net-10-million-passwords-1000000.txt --show

# hashcat -m 6900 "$hash" \
# $dir \
# --show

dir="/home/smm/hw-linux/seclists/Passwords/Common-Credentials"
# hash='5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab'
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

    # hashcat -m "$m" "$hash" "$f"/* --show
    out=$(hashcat -m "$m" "$hash" --show 2>/dev/null)

    rc=$?

    case $rc in
      # 0) echo "[+] FOUND"; exit 0 ; grep -q -E "^${hash}:" "$outfile" ;;
      0) echo "[+] FOUND" >> "$outfile"; out >> "$outfile";;
      1) ;;  # not found
      255) echo "[-] leght is wrong"; continue ;;
      *) echo "[!] error rc=$rc" >&2 ;;
    esac

  done
done 


exit 1


# hashcat -m "$m" "$hash" "$f"/* \
    #   --potfile-disable \
    #   --outfile="$outfile" --outfile-autohex-disable \
    #   --quiet >/dev/null 2>&1
      
    # rc=$?
    # case $rc in
    #   0) echo "[+] FOUND"; exit 0 ; grep -q -E "^${hash}:" "$outfile" ;;
    #   1) ;;  # not found
    #   255) echo "[-] leght is wrong" && continue ;;
    #   *) echo "[!] error rc=$rc" >&2 ;;
    # esac

    # echo "[x] No match in provided modes/wordlists"