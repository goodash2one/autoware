#!/bin/bash

if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ]; then
    echo "usage: $0 <repo:tag> [\"network\"] [id(0~101)]"
    exit
fi

IMAGE=$1

XSOCK=/tmp/.X11-unix
XAUTH=$XAUTHORITY 
SHARED_DOCK_DIR=/shared_dir
SHARED_HOST_DIR=/home/$USER/shared_dir

DEVICES="--device /dev/snd --device /dev/dri"

VOLUMES="--volume=$XSOCK:$XSOCK:ro
	 --volume=$XAUTH:/root/.Xauthority:ro
	 --volume=$SHARED_HOST_DIR:$SHARED_DOCK_DIR:rw
	 --volume=/media:/media:rw
	 --volume=/dev/shm:/dev/shm:rw
	 --volume=/dev/ttyUSB0:/dev/ttyUSB0:ro"
	 
ENVIRONS="--env DISPLAY=$DISPLAY
	  --env SDL_VIDEODRIVER=x11
	  --env XAUTHORITY=/root/.Xauthority"

if [ "$2" == "network" ] || [ "$2" == "NETWORK" ] || \
   [ "$2" == "net" ] || [ "$2" == "NET" ]; then
    ENVIRONS="$ENVIRONS --env ROS_LOCALHOST_ONLY=0"
elif [ "$2" == "local" ] || [ "$2" == "LOCAL" ] || \
     [ -z "$2" ]; then
    ENVIRONS="$ENVIRONS --env ROS_LOCALHOST_ONLY=1"
else
    echo "invalid arg: $2"
    exit
fi

if [[ "$3" =~ ^[0-9]+$ ]] && [ "$3" -ge 0 ] && [ "$3" -le 101 ]; then
    ENVIRONS="$ENVIRONS --env ROS_DOMAIN_ID=$3"
elif [ -n "$3" ]; then
    echo "invalid arg: $3"
    exit
fi

GPU='--gpus all,"capabilities=graphics,utility,display,video,compute"' 
#GPU='--gpus all'

FULL_CMD="docker run -it \
	--privileged \
	--net=host \
 	--runtime=nvidia \
	$GPU \
	$DEVICES \
	$ENVIRONS \
	$VOLUMES \
	$IMAGE"

if [ ! -d $SHARED_HOST_DIR ]; then
    mkdir $SHARED_HOST_DIR
fi

echo $FULL_CMD

$FULL_CMD
