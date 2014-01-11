#!/bin/bash

if [ "$3" = "upload" ]; then
    flac "$1"
    cd /home/ubuntu/demo/ahks/ahks/speech/transcribe/
	python transcribe.py "$4.flac" $2 
else
    flac "$1.wav"
    cd /home/ubuntu/demo/ahks/ahks/speech/transcribe/
	python transcribe.py "$1.flac" $2 
fi


