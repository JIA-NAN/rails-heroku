#!/usr/bin/env python2
#
# Example to compare the faces in two images.
# Brandon Amos
# 2015/09/29
#
# Copyright 2015-2016 Carnegie Mellon University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import time
import sys

start = time.time()

import argparse
import cv2
import itertools
import os

import numpy as np
np.set_printoptions(precision=2)

import openface



# this script uses openface to recognize a face in a video. It compares each frame of a video with a given image and 
# ouput a score that ranges from 0 (the same picture) to 4.0 (total different)
# Then, it calculates average score and compare with THRESH_HOLD
# reference: https://cmusatyalab.github.io/openface/demo-2-comparison/

SKIP_SECOND = 2
MAX_SECOND = 7
THRESH_HOLD = 0.35 

def is_cv3():

    return cv2.__version__.startswith("3.")


fileDir = "/app/.heroku/vendor/openface"

modelDir = os.path.join(fileDir, 'models')
dlibModelDir = os.path.join(modelDir, 'dlib')
openfaceModelDir = os.path.join(modelDir, 'openface')

parser = argparse.ArgumentParser()

parser.add_argument('imgs', type=str, nargs='+', help="Input images.")
parser.add_argument('--dlibFacePredictor', type=str, help="Path to dlib's face predictor.",
                    default=os.path.join(dlibModelDir, "shape_predictor_68_face_landmarks.dat"))
parser.add_argument('--networkModel', type=str, help="Path to Torch network model.",
                    default=os.path.join(openfaceModelDir, 'nn4.small2.v1.t7'))
parser.add_argument('--imgDim', type=int,
                    help="Default image dimension.", default=96)
parser.add_argument('--verbose', action='store_true')

args = parser.parse_args()

if args.verbose:
    print("Argument parsing and loading libraries took {} seconds.".format(
        time.time() - start))

start = time.time()
align = openface.AlignDlib(args.dlibFacePredictor)
net = openface.TorchNeuralNet(args.networkModel, args.imgDim)
if args.verbose:
    print("Loading the dlib and OpenFace models took {} seconds.".format(
        time.time() - start))


def getRep(bgrImg, imgPath):


    if bgrImg is None:
        return None 

        print ("Unable to load image: {}".format(imgPath))

        # raise Exception("Unable to load image: {}".format(imgPath))
    rgbImg = cv2.cvtColor(bgrImg, cv2.COLOR_BGR2RGB)

    if args.verbose:
        print("  + Original size: {}".format(rgbImg.shape))

    start = time.time()
    bb = align.getLargestFaceBoundingBox(rgbImg)
    if bb is None:

        #print ("Unable to find a face: {}".format(imgPath))
        # Unable to find a face in frame


        return None 


        # raise Exception("Unable to find a face: {}".format(imgPath))
    if args.verbose:
        print("  + Face detection took {} seconds.".format(time.time() - start))

    start = time.time()
    alignedFace = align.align(args.imgDim, rgbImg, bb,
                              landmarkIndices=openface.AlignDlib.OUTER_EYES_AND_NOSE)
    if alignedFace is None:

        return None

        #print ("Unable to align image: {}".format(imgPath))

        # raise Exception("Unable to align image: {}".format(imgPath))
    if args.verbose:
        print("  + Face alignment took {} seconds.".format(time.time() - start))

    start = time.time()
    rep = net.forward(alignedFace)
    if args.verbose:
        print("  + OpenFace forward pass took {} seconds.".format(time.time() - start))
        print("Representation:")
        print(rep)
        print("-----\n")
    return rep


def rotate_image_90(im, angle):
    if angle % 90 == 0:
        angle = angle % 360
        if angle == 0:
            return im
        elif angle == 90:
            return im.transpose((1,0, 2))[:,::-1,:]
        elif angle == 180:
            return im[::-1,::-1,:]
        elif angle == 270:
            return im.transpose((1,0, 2))[::-1,:,:]

    else:
        raise Exception('Error')

def main():

    if len(sys.argv) != 4: 

        print ("Incorrect parameters")

        print sys.argv

        print ("Usage: python face_recognition.py path/to/video /path/to/image angle")

        return

    video_path = sys.argv[1]

    photo_path = sys.argv[2]


    rotation = sys.argv[3]


    video_capture = cv2.VideoCapture(video_path)


    if is_cv3() : 

        fps = video_capture.get(cv2.CAP_PROP_FPS)

    else : 

        fps = video_capture.get(cv2.cv.CV_CAP_PROP_FPS) 
 

    counter = 0 

    score_list = []

    last_frame_index = 0 

    while True : 


        ret, frame = video_capture.read()


        if not ret : 


            break 

        if is_cv3() :

            current_frame_number = video_capture.get(cv2.CAP_PROP_POS_FRAMES)

        else:   

            current_frame_number = video_capture.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)


        if current_frame_number - last_frame_index < SKIP_SECOND * fps: 

                continue

        if current_frame_number - last_frame_index > MAX_SECOND * fps: 

                break 

        frame = rotate_image_90(frame, int(rotation))

        #cv2.imwrite(str(counter)+".jpg", frame)

        bgrImg = cv2.imread(photo_path)

        rep1 = getRep(frame, video_path)
        rep2 = getRep(bgrImg, photo_path)

        if rep2 is None: 

            # cannot detect face in the image

            break 

        if rep1 is None: 

            # cannot detect face in the video frame 

            continue


        else: 


            d = rep1 - rep2

            score_list.append(np.dot(d,d))

            last_frame_index = current_frame_number



    

    if len(score_list) == 0: 

        print ("{ \"is_face_recognized\": false, \"face_recognition_score\": 4}")

    else : 

        average = sum(score_list)/len(score_list)


        if average < THRESH_HOLD : 

            print ("{ \"is_face_recognized\": true, \"face_recognition_score\": " + str(average) + "}")


        else :

            print ("{ \"is_face_recognized\": false, \"face_recognition_score\": " + str(average) + "}")

        

main()



