#!/bin/bash

#Make the directory for the temporary file storage if it doesn't exist yet
if [ ! -d "${HOME}/TEMP" ]; then
        echo "TEMP directory not found! Creating it now"
        mkdir -p "${HOME}/TEMP"
fi

#The actual work 
for i in {1..10}; do

curl -o "${HOME}/TEMP/cam.jpg http://link.to/camimage.jpg"
if [[ -s ${HOME}/TEMP/cam.jpg ]] ; then
echo "We have the image."
echo "Sending email now!"
mpack -s TrafficCam -a "${HOME}/TEMP/cam.jpg" USERNAME@gmail.com
echo "Email sent!"
rm "${HOME}/TEMP/cam.jpg"
sleep 60
else
echo "Whoops, lemme retry that..."
rm "${HOME}/TEMP/cam.jpg"
sleep 60
fi

done
