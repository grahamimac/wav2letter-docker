#!/bin/bash

# Pre-process data
for f in dev-clean train-clean-100 train-clean-360 train-other-500 dev-other test-clean test-other; do
wget http://www.openslr.org/resources/12/${f}.tar.gz
tar xfvz ${f}.tar.gz
rm ${f}.tar.gz
done
~/usr/bin/luajit /wav2letter/data/librispeech/create.lua /LibriSpeech /librispeech-proc
~/usr/bin/luajit /wav2letter/data/utils/create-sz.lua /librispeech-proc/train-clean-100 /librispeech-proc/train-clean-360 /librispeech-proc/train-other-500 /librispeech-proc/dev-clean /librispeech-proc/dev-other /librispeech-proc/test-clean /librispeech-proc/test-other
rm -rf /LibriSpeech

# Run the decoder
cat /librispeech-proc/letters.lst >> /librispeech-proc/letters-rep.lst && echo "1" >> /librispeech-proc/letters-rep.lst && echo "2" >> /librispeech-proc/letters-rep.lst
wget http://www.openslr.org/resources/11/3-gram.pruned.3e-7.arpa.gz
~/usr/bin/luajit /wav2letter/data/utils/convert-arpa.lua /3-gram.pruned.3e-7.arpa.gz /3-gram.pruned.3e-7.arpa /librispeech-proc/dict.lst -preprocess /wav2letter/data/librispeech/preprocess.lua -r 2 -letters /librispeech-proc/letters-rep.lst
~/usr/bin/build_binary 3-gram.pruned.3e-7.arpa 3-gram.pruned.3e-7.bin
rm 3-gram.pruned.3e-7.arpa.gz 3-gram.pruned.3e-7.arpa

# Get model and pre-train
wget https://s3.amazonaws.com/wav2letter/models/librispeech-glu-highdropout-cpu.bin

# Ready
# Example: ~/usr/bin/luajit /wav2letter/test.lua /librispeech-glu-highdropout-cpu.bin -progress -show -test dev-clean -save -datadir /librispeech-proc/ -dictdir /librispeech-proc/ -gfsai