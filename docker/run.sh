#!/bin/bash

if [ $# -ne 1 ]
then
        echo "usage: $0 <repo:tag>"
        exit
fi

IMAGE=$1

XSOCK=/tmp/.X11-unix
XAUTH=$XAUTHORITY 
VULKAN=/usr/share/vulkan

DEVICES="--device /dev/snd --device /dev/dri"

VOLUMES="--volume=$XSOCK:$XSOCK:ro	 
	 --volume=$XAUTH:$XAUTH:ro
	 --volume=/media:/media:rw
	 --volume=/dev/shm:/dev/shm:rw
	 --volume=/dev/ttyUSB0:/dev/ttyUSB0:ro"
	 #--volume=$VULKAN:$VULKAN:rw
	 
ENVIRONS="--env DISPLAY=$DISPLAY
	  --env SDL_VIDEODRIVER=x11
	  --env XAUTHORITY=$XAUTHORITY"

GPU='--gpus all,"capabilities=graphics,utility,display,video,compute"' 
#GPU='--gpus all'

FULL_CMD="docker run -it \
	--privileged \
	--net=host \
	$GPU \
	$DEVICES \
	$ENVIRONS \
	$VOLUMES \
	$IMAGE"	 


echo $FULL_CMD

$FULL_CMD
