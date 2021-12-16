#!/bin/bash
cd ExtractLightPositions
ffmpeg -i view0.mov -s 540x960  view0/frame%06d.png
ffmpeg -i view1.mov -s 540x960  view1/frame%06d.png
ffmpeg -i view2.mov -s 540x960  view2/frame%06d.png
ffmpeg -i view3.mov -s 540x960  view3/frame%06d.png
cd ..