#!/usr/local/bin/python

# cam 0 is HAND
# cam 1 is FACE

import cv2
import sys
from video import create_capture
from common import clock, draw_str

cascade_fn = "/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml"

def take_photo(argv):
    face_found = False
    
    #Which type? Hand or Face
    which_cam = 1
    name = "face"
    if argv:
        if argv[0] == "hand":
            which_cam = 0
            name = "hand"

    cascade = cv2.CascadeClassifier(cascade_fn)
    cam = create_capture(which_cam)
            
    while True:
        ret, img = cam.read()
        if name == "face" :
            # Do a little preprocessing:
            img_copy = cv2.resize(img, (img.shape[1]/2, img.shape[0]/2))
            gray = cv2.cvtColor(img_copy, cv2.COLOR_BGR2GRAY)
            gray = cv2.equalizeHist(gray)
            # Detect the faces (probably research for the options!):
            rects = cascade.detectMultiScale(gray)
            # Make a copy as we don't want to draw on the original image:
            for x, y, width, height in rects:
                if 475 < x < 775 : 
                    #cv2.rectangle(img_copy, (int(x-width*0.35), int(y-height/2)), (int(x+width*1.5), int(y+height*1.5)), (255,0,0), 2)
                    #Save face
                    cropped = cv2.getRectSubPix(img, (int(width*2)*2, int(height*2)*2), (int(x+width/2)*2, int(y+height/2)*2))
                    cv2.imwrite("static/captured/" + name + argv[1] + ".png", cropped)
                    face_found = True

            #cv2.imshow('facedetect', cropped)
            if cv2.waitKey(20) == 27:
                break
            if face_found:
                break
        else:
            #920 x 730 at 420, 60
            cropped = cv2.getRectSubPix(img, (920,730), (int(420+920/2), int(60+730/2)))
            cv2.imwrite("static/captured/" + name + argv[1] + ".png", cropped)
            break

if __name__ == '__main__': 
    take_photo(sys.argv[1:])