#!/bin/bash

# sudo hashcat -m 6900 5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab /home/smm/hw-linux/seclists/Passwords/Common-Credentials/xato-net-10-million-passwords-1000000.txt --show

# hashcat -m 6900 "$hash" \
# $dir \
# --show

dir="/home/smm/hw-linux/seclists/Passwords/Common-Credentials"
# hash='5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab'
hash=$1
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

# : > "$outfile"
for f in "$dir"/*; do
  for m in "${modes[@]}"; do
  
    echo "Try mode $m in file $f"
    [[ -f "$f" ]] || continue

    hashcat -m "$m" "$hash" "$f"/* --show

    rc=$?

    case $rc in
      0) echo "[+] FOUND"; exit 0 ; grep -q -E "^${hash}:" "$outfile" ;;
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