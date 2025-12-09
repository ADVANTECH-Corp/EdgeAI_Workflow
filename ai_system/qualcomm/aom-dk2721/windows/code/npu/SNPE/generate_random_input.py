import cv2
import numpy as np
import glob

# Get the list of all jpg images in the directory
img_list = glob.glob("./quant_imgs_320/*.jpg")

f = open("img_list.txt", "w")

f.write("%output0\n") # Adjust according to model output names

for img_path in img_list:
    img = cv2.imread(img_path)
    
    # Normalize image data to [-1, 1] range
    img = (np.float32(img) - 127.5) / 127.5
    
    output_raw_path = img_path + ".raw"
    
    # Save the normalized image as a binary file
    img.astype(np.float32).tofile(output_raw_path)
    
    # Write the path to the list file
    f.write("images:=" + output_raw_path + "\n")

f.close()
