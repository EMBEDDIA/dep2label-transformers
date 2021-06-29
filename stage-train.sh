#!/bin/bash
# Usage: ./stage-eval.sh trainlang bertmodel type suffix
# where trainlang is the language you want to train/finetune the model on,
# bertmodel is the string identificator/name of the transformer model as used on huggingface, or alternatively path to the model that you want to finetune.
# type is either bert of roberta, depending on which of the two training approaches the model is based on.
# optionally, you can add any suffix to the finetuned model name.

lang=$1
BERT_MODEL=$2
TRANSFORMER_TYPE=$3
SUFFIX=$4

enc="arc-standard"
SEQ_LENGTH=512
epochs=10 # 45
LOG=log/
PATH_GOLD=./gold/$lang/dev.conllu
MODEL_NAME=$(echo "${BERT_MODEL}-e${epochs}-run${SUFFIX}" | sed 's|/||g')
echo $MODEL_NAME
MODEL_DIR=./models/$enc/models/$lang/

mkdir -p gold/$lang
mkdir -p log/${lang}
mkdir -p models/${lang}/$MODEL_NAME
mkdir -p output/${lang}/$MODEL_NAME

python run_token_classifier.py \
    --status train \
    --data_dir data/encoded/${lang}-${enc} \
    --transformer_model $TRANSFORMER_TYPE \
    --transformer_pretrained_model $BERT_MODEL \
    --task_name sl_tsv \
    --model_dir models/${lang}/$MODEL_NAME \
    --output_dir output/${lang}/$MODEL_NAME \
    --path_gold_conllu $PATH_GOLD \
    --path_predicted_conllu $PATH_GOLD \
    --label_split_char {} \
    --log log/${lang}/$MODEL_NAME \
    --learning_rate 1e-5 \
    --encoding $enc \
    --max_seq_length $SEQ_LENGTH \
    --do_train --do_eval --num_train_epochs ${epochs} --train_batch_size 8 | tee -a models/${lang}/${MODEL_NAME}/training.log

