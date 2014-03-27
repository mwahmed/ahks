#!/bin/bash

if [ "$3" = "upload" ]; then
    flac "$1"
    echo "Converted to FLAC"
    cd /home/ubuntu/falcon/transcribe/
	python transcribe.py "$4.flac" $2 
else
    flac "$1.wav"
    echo "Converted to FLAC"
    cd /home/ubuntu/falcon/transcribe/
	python transcribe.py "$1.flac" $2 
fi


