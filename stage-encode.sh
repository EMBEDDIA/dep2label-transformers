#!/bin/bash

# "UD_Slovenian-SSJ" "UD_Croatian-SET" "UD_English-EWT" "UD_Estonian-EDT" "UD_Finnish-TDT" "UD_Latvian-LVTB" "UD_Lithuanian-HSE" "UD_Swedish-Talbanken" "UD_Russian-GSD"

declare -a languages=("English" "Slovenian" "Croatian" "Finnish" "Estonian" "Latvian" "Lithuanian" "Swedish" "Russian")
declare -a dataset=("EWT" "SSJ" "SET" "TDT" "EDT" "LVTB" "HSE" "Talbanken" "GSD")
declare -a dataset2=("en_ewt" "sl_ssj" "hr_set" "fi_tdt" "et_edt" "lv_lvtb" "lt_hse" "sv_talbanken" "ru_gsd")
enc="arc-standard"
SEQ_LENGTH=512
LOG=log/

for i in 0 1 2 3 4 5 6 7 8
do
    lang=${languages[$i]}
    mkdir -p gold/$lang
    mkdir -p log/${lang}
    mkdir -p data/encoded/${lang}-${enc}
    for split in train dev test
    do
      python encode_dep2labels.py \
      --input data/ud-treebanks/UD_${lang}-${dataset[$i]}/${dataset2[$i]}-ud-${split}.conllu \
      --output data/encoded/${lang}-${enc}/${split}.tsv \
      --encoding $enc
    done
    for split in dev test
    do
      cp data/ud-treebanks/UD_${lang}-${dataset[$i]}/${dataset2[$i]}-ud-${split}.conllu gold/${lang}/${split}.conllu
    done
done
