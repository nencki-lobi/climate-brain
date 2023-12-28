#!/bin/bash

cd ./data/logs

## Remove all `cet_training` custom logfiles

find . -name '*cet_training*custom.txt' -delete

## Remove unwanted logfiles

rm -f '3011h-stories_R1-20231130-160614-WYLBD.log'
rm -f '0212d-stories_R1-20231202-121637-OYMRK.log'
rm -f '0512a-stories_R1-20231205-091750-JZSCO.log'
rm -f '0712b-stories_R1-20231207-103417-HBMAV.log'
rm -f '0812g-stories_R1-20231208-152113-HTDYT.log'
rm -f '1912d-stories_R1-20231219-115311-OKXTP.log'
rm -f '2112c-stories_R1-20231221-113858-CZSWA.log'

rm -f '0512f-cet-20231205-135332-WWQSZ-custom.txt'
rm -f '0512f-cet-20231205-135332-WWQSZ.log'

## Fix subject codes

# Define function for later reuse

fixlogs() {
  local old_prefix="$1"
  local new_prefix="$2"
  local files=("${@:3}")

  for file in "${files[@]}"; do
    
    new_file=$(echo "$file" | sed "s/$old_prefix/$new_prefix/g")
    
    mv "$file" "$new_file" # Rename file
    sed -i '' "s/$old_prefix/$new_prefix/g" "$new_file" # Find and replace
  done
}

# 0712h

files_0712h=(
'0812h-stories_R1-20231207-161319-DDPJF.log'
'0812h-stories_R2-20231207-161843-NRXKD.log'
'0812h-stories_R3-20231207-162400-HBAQG.log'
'0812h-cet-20231207-163536-NELLZ-custom.txt'
'0812h-cet-20231207-163536-NELLZ.log'
)

fixlogs "0812h" "0712h" "${files_0712h[@]}"

# 1012b

files_1012b=(
'012b-stories_R1-20231210-103404-JDKQX.log'
'012b-stories_R2-20231210-103916-EAKSJ.log'
'012b-stories_R3-20231210-104423-HSBOK.log'
'012b-cet-20231210-105834-INVCH-custom.txt'
'012b-cet-20231210-105834-INVCH.log'
)

fixlogs "012b" "1012b" "${files_1012b[@]}"

# 1212b

files_1212b=(
'212b-stories_R1-20231212-101347-UTSNH.log'
'212b-stories_R2-20231212-101858-TJHEE.log'
'212b-stories_R3-20231212-102403-RNUEJ.log'
'212b-cet-20231212-103748-EVXUO-custom.txt'
'212b-cet-20231212-103748-EVXUO.log'
)

fixlogs "212b" "1212b" "${files_1212b[@]}"

# 1412e

files_1412e=(
'1413e-stories_R1-20231214-132244-KSYYB.log'
'1413e-stories_R2-20231214-132752-LXBSZ.log'
'1413e-stories_R3-20231214-133302-QBYYC.log'
'1413e-cet-20231214-134636-GYOTB-custom.txt'
'1413e-cet-20231214-134636-GYOTB.log'
)

fixlogs "1413e" "1412e" "${files_1412e[@]}"

# 1812h

files_1812h=(
'1218h-stories_R1-20231218-155200-KPBVO.log'
'1218h-stories_R2-20231218-155711-UCNZL.log'
'1218h-stories_R3-20231218-160218-FSYGQ.log'
'1218h-cet-20231218-161337-QNMFF-custom.txt'
'1218h-cet-20231218-161337-QNMFF.log'
)

fixlogs "1218h" "1812h" "${files_1812h[@]}"

# 1812i

files_1812i=(
'1812a-stories_R1-20231218-172927-KYKEY.log'
'1812a-stories_R2-20231218-173450-TYHYJ.log'
'1812a-stories_R3-20231218-174001-TMXVC.log'
'1812a-cet-20231218-175407-ETKZG-custom.txt'
'1812a-cet-20231218-175407-ETKZG.log'
)

fixlogs "1812a" "1812i" "${files_1812i[@]}"
