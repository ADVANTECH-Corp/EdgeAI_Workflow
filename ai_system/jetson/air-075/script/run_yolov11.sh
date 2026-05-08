#! /bin/bash



#######################################################################################################
#######################################################################################################
##edit :




app_config_file=deepstream_app_config_yoloV11.txt
app_config_default_file=deepstream_app_config_yoloV11_default.txt





# for usb Camera
 
WIDTH=$2
HEIGHT=$3
FPS=$4


echo run_yolov11: USB - Camera : $WIDTH x $HEIGHT, FPS=$FPS

#######################################################################################################
#######################################################################################################
#######################################################################################################

func_init(){
  
  cd "$(pwd)"

}



func_handle_file(){

 file1=$app_config_file
 fileDefault=$app_config_default_file
  
 if [ -f "$file1" ];then
 
    rm -rf "$file1"
   
 fi
  
   cp "$fileDefault" "$file1"
   chmod 777 "$file1"

}




func_edit_source_file(){

  destfile=$app_config_file
   
  echo ' ' >> "$destfile" 
  echo '[source0]' >> "$destfile"
  echo 'enable=1' >> "$destfile" 
  #Type - 1=CameraV4L2 2=URI 3=MultiURI 
  echo 'type=3' >> "$destfile"
  echo 'uri=file://'"$1" >> "$destfile"
  echo 'num-sources=1' >> "$destfile"
  echo 'gpu-id=0' >> "$destfile"
  echo 'cudadec-memtype=0' >> "$destfile" 
  echo ' ' >> "$destfile"
  
  echo "func_edit_source_file  !"   

}






func_edit_source_camera(){

  # func_handle_usb_camera_setting $1 

  destfile=$app_config_file
  
  echo ' ' >> "$destfile" 
  echo '[source0]' >> "$destfile"
  echo 'enable=1' >> "$destfile" 
  echo 'type=1' >> "$destfile"
  echo "camera-width=$WIDTH" >> "$destfile"
  echo "camera-height=$HEIGHT" >> "$destfile"
  echo "camera-fps-n=$FPS" >> "$destfile"
  echo "camera-fps-d=1" >> "$destfile"
  echo "camera-v4l2-dev-node="$1 >> "$destfile"  
  #video-format
  #echo 'video-format=NV12' >> "$destfile"  
  echo ' ' >> "$destfile"
  
  

}

 

func_process_inputfile(){

inputfile="$1"
string_check="/dev/video"
if [[ $inputfile == *"$string_check"* ]];then
   str="$inputfile"
   find="$string_check"
   replace=""
   # notice the the str isn't prefixed with $
   #    this is just how this feature works :/
   result=${str//$find/$replace}
   inputfile=$result
   echo "It's camera  !"
   func_edit_source_camera $inputfile 
else
   echo "It's file  !"   
   func_edit_source_file "$inputfile" 
fi
   
   echo "$inputfile"
   
}



func_execute_app(){
 
  ./deepstream-app -c "$app_config_file"
   #  ./deepstream-app-OK -c "$app_config_file"
}



func_init

func_handle_file
 
func_process_inputfile "$1" 
 
func_execute_app



 
 

