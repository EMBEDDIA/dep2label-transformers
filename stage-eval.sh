#!/bin/bash

# Usage: ./stage-eval.sh trainlang testlang bertmodel type suffix
# where trainlang is the language the model was trained on, testlang is the language you want to evaluate the model on,
# bertmodel is the string identificator/name of the transformer model as used on huggingface, or alternatively path to the model.
# type is either bert of roberta, depending on which of the two training approaches the model is based on.
# suffix is any suffix that was applied to the model name during the training stage.

train_lang=$1
test_lang=$2
BERT_MODEL=$3
TRANSFORMER_TYPE=$4
SUFFIX=$5
enc="arc-standard"
SEQ_LENGTH=256
epochs=10 # 45
LOG=log/
MODEL_NAME=$(echo "${BERT_MODEL}-e${epochs}-run${SUFFIX}" | sed 's|/||g')
echo $MODEL_NAME
MODEL_DIR=./models/$enc/models/${train_lang}/
mkdir -p output/${train_lang}-${test_lang}/$MODEL_NAME
for split in dev test
do
if [[ $split == "dev" ]]
then
task="eval"
else
task="test"
fi

PATH_GOLD=./gold/${test_lang}/${split}.conllu
# load finetuned model and run evaluation on test set
python run_token_classifier.py \
    --status test \
    --data_dir data/encoded/${train_lang}-${test_lang}-${enc} \
    --transformer_model $TRANSFORMER_TYPE \
    --transformer_pretrained_model $BERT_MODEL \
    --task_name sl_tsv \
    --model_dir models/${train_lang}/$MODEL_NAME \
    --output_dir output/${train_lang}-${test_lang}/$MODEL_NAME \
    --path_gold_conllu $PATH_GOLD \
    --path_predicted_conllu $PATH_GOLD \
    --label_split_char {} \
    --log log/${train_lang}/$MODEL_NAME \
    --learning_rate 1e-5 \
    --encoding $enc \
    --max_seq_length $SEQ_LENGTH \
    --do_${task} --num_train_epochs ${epochs} --train_batch_size 8


# convert predictions to conllu format
python decode_labels2dep.py \
  --input "output/${train_lang}-${test_lang}/${MODEL_NAME}.${split}.outputs.txt.seq_lu" \
  --conllu_f "gold/${test_lang}/${split}.conllu" \
  --output "output/${train_lang}-${test_lang}/${MODEL_NAME}/${split}.prediction.conllu" \
  --encoding ${enc}

# print scores
python conll18_ud_eval.py -v gold/${test_lang}/${split}.conllu output/${train_lang}-${test_lang}/${MODEL_NAME}/${split}.prediction.conllu > output/${train_lang}-${test_lang}/${MODEL_NAME}/${split}.scores.txt

done
