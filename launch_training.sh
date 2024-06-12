#!/bin/bash


echo "Starting .. "
python3 -m venv ./.venv 
source "./.venv/bin/activate"
echo "Virtual environement < .venv > created and activated"
echo "____________________________________________________"
echo "Installing ultralytics.." 
pip install ultralytics 1> /dev/null
echo "Ultralytics installed sucessfully"
echo "_________________________________"
echo "Please enter roboflow dataset link below else just click enter :"
read url 

if [ -n "$url" ]; then 
	echo "Downloading dataset .."
	curl -L "$url" > customDs.zip 
	mkdir customDs
	unzip customDs.zip -d ./customDs  1> /dev/null 
	rm -rf customDs.zip


# Define the file path
FILE="./customDs/data.yaml"

# Use sed to replace the lines
sed -i 's#train: ../train/images#train: ./train/images#' $FILE
sed -i 's#val: ../valid/images#val: ./valid/images#' $FILE
sed -i 's#test: ../test/images#test: ./test/images#' $FILE


# Path to the configuration file settings.yaml
config_file="$HOME/.config/Ultralytics/settings.yaml"
# Get the current directory
current_dir=$(pwd)

sed -i "s|datasets_dir:.*|datasets_dir: $current_dir|g" "$config_file"
	echo "Datset downloaded sucessfully"
	echo "customDs/data.yaml modified (setting augmentation setting to 0)"
	echo "datasets_dir has been updated to the current directory: $current_dir in settings.yaml"
	echo "_______________________________________________________________"
else 
	echo "Please place your data in ./customDs contains (train, valid, test and data.yaml)"
	echo "________________________________________________________________________________"
fi

echo "You want to perform training now ? (y/n) "
read answer
if [[ $answer == "y" || $answer == "yes" ]];
then 
	echo "Please enter the batch size"
	read bsize
	echo "___________________________"
	echo "Please enter nb of epochs"
	read epochs
	echo "___________________________"
	echo "The number of cuda devices (ex : 1,2,3,4) let it empty for device 0 or cpu"
	read devices 
	echo "__________________________________________________________________________"
	yolo detect train cfg=./config.yaml data=./customDs/data.yaml model=yolov8n.yaml pretrained=yolov8n.pt epochs=$epochs batch=$bsize imgsz=640 device=$devices plots=True
else 
	echo "Script stopped you can launch training manually, use :"
	echo "yolo detect train data=data.yaml model=yolov8n.pt epochs=x batch=y imgsz=640 device=z"
	exit 1
fi
