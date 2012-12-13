#!/usr/local/bin/python

import cv2
import sys

def take_photo(argv):
    which_cam = 0
    name = "hand"
    if argv:
        if argv[0] == "face":
            which_cam = 1
            name = "face"
    vidcap = cv2.VideoCapture()
    vidcap.open(which_cam)
    retval, image = vidcap.retrieve()
    vidcap.release()
    cv2.imwrite("/Users/johnryan/Sites/multiplex.me/static/captured/" + name + argv[1] + ".png", image)

if __name__ == '__main__': 
    take_photo(sys.argv[1:])
