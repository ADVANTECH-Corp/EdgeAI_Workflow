
# test for gst-ai-object


export XDG_RUNTIME_DIR=/dev/socket/weston && export WAYLAND_DISPLAY=wayland-1
source /opt/qcom/qirp-sdk/qirp-setup.sh


#model=yolov8_det.tflite

model=yolov8_det_quantized.tflite

label=coco_labels.txt

external=libQnnTFLiteDelegate.so




#setprop persist.overlay.use_c2d_blit 2



gst-launch-1.0 -e filesrc location="ObjectDetection.mp4" ! qtdemux ! queue ! h264parse ! v4l2h264dec capture-io-mode=5 output-io-mode=5 ! queue ! tee name=split  \
split. ! queue ! qtivcomposer name=mixer sink_1::dimensions="<640,480>" sink_1::alpha=0.5 ! queue ! waylandsink fullscreen=false width=1280 height=720 \
split. ! queue ! qtivtransform ! video/x-raw\(memory:GBM\),format=NV12,width=640,height=480 ! qtimlvconverter ! queue ! qtimltflite delegate=external external-delegate-path=$external \
external-delegate-options="QNNExternalDelegate,backend_type=htp;" model=$model ! queue ! \
qtimlvdetection threshold=31.0 results=5 module=yolov8 labels=$label \
constants="YOLOv8,q-offsets=< 20.0, 0.0, 0.0>,q-scales=<3.1391797,0.0037510, 1.0>;" ! video/x-raw,format=BGRA,width=640,height=360 ! queue ! mixer.









