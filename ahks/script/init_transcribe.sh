#!/bin/bash

flac --keep-foreign-metadata "$1.wav"

cd /home/user/496_web/falcon/transcribe/
python transcribe.py "$1.flac" $2 