#!/bin/bash 

req="{python3, pip, virtualenv, git}"

echo -e "As an initial requirement you need $req.\nThe requirement is already satisfied?(y/n)"
read response


if [[ $response == "y" || $response == "yes" ]];
then	
	
	echo "Executing the script.."
	mkdir trainingProject 
	cd trainingProject 
	virtualenv yolovenv
	source "./yolovenv/bin/activate"
	# Begin working on yolovenv virtual environement 
	git clone https://github.com/WongKinYiu/yolov7.git
	cd yolov7
	pip install -r requirements.txt 
	echo "from roboflow.com, get your Download code {Raw URL} of your custom dataset for yolov7 for and paste it below"
	read url
	curl -L "$url" > roboflow.zip
	unzip roboflow.zip -d customDataset
	rm -rf roboflow.zip

	# Getting the model yolov7-tiny
	wget "https://github.com/WongKinYiu/yolov7/releases/download/v0.1/yolov7-tiny.pt"
	
	echo -e "You want to Train the model now? (y/n)"
	read response
	if [[ $response == "y" || $response == "yes" ]];
	then 
		
		# Training the model
		echo "Enter the batch size : "
		read bsize
		echo - "\nEnter the number of epochs : "
		read epochs
		python3 train.py --batch $bsize --cfg cfg/training/yolov7-tiny.yaml --epochs $epochs --data ./customDataset/data.yaml --weights 'yolov7-tiny.pt' 
		echo "Done"
	else
		echo -e "To run the trainig process make sure the virtual environment 'yolov7' is activated.\n"
		echo -e "Copy the command below and run it from the current directory specifying the parameters : \n"
		echo -e "python3 train.py --batch <BSIZE> --cfg cfg/training/yolov7-tiny.yaml --epochs <EPOCHS> --data ./customDataset/data.yaml --weights 'yolov7-tiny.pt'"
  		deactivate
		exit 2
	fi
else 
	rm -rf trainingProject
	cd ..
	echo "Script stopped, please install $req"
	exit 1
fi

