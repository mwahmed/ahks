#!/bin/bash

if [ "$3" = "upload" ]; then
    flac --keep-foreign-metadata "$1"
    cd /home/user/496_web/falcon/transcribe/
	python transcribe.py "$4.flac" $2 
else
    flac --keep-foreign-metadata "$1.wav"
    cd /home/user/496_web/falcon/transcribe/
	python transcribe.py "$1.flac" $2 
fi


