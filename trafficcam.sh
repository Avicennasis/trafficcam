#!/bin/bash

for i in {1..10}; do curl -o ~/TEMP/cam.jpg http://link.to/camimage.jpg ; mpack -s TrafficCam -a ~/TEMP/cam.jpg USERNAME@gmail.com ; rm ~/TEMP/cam.jpg ; sleep 60 ; done
