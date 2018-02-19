import cv2
import sys
import os
import numpy as np
import shutil
import dlib
import math


# this script uses Face Landmark Detection - Dlib to detect 8 points in the mouth
# it then calculates the ratio between distance of the upper point and lower point and distance of leftmost point and rightmost point
# threshold to check if the mouth is open, if the ratio > RATIO_THRESHOLD, the mouth is open 
# reference: http://www.pyimagesearch.com/2017/04/03/facial-landmarks-dlib-opencv-python/

RATIO_THRESHOLD = 0.21 
SKIP_SECOND = 1
MAX_SECOND = 3

# check version of opencv 
def is_cv3():

    return cv2.__version__.startswith("3.")


# calculate distance from p to (p1, p2)
def distance_to_line(p, p1, p2):
        x_diff = p2.x - p1.x
        y_diff = p2.y - p1.y
        num = abs(y_diff*p.x - x_diff*p.y + p2.x*p1.y - p2.y*p1.x)
        den = math.sqrt(y_diff**2 + x_diff**2)
        return num / den


# calculate between p1 and p2
def distance_line (p1, p2):

    return math.sqrt( (p1.x - p2.x)**2 + (p1.y - p2.y)**2 )



detector = dlib.get_frontal_face_detector()

predictor = dlib.shape_predictor("/app/.heroku/vendor/openface/models/dlib/shape_predictor_68_face_landmarks.dat")

# "/app/.heroku/vendor/openface/models/dlib/shape_predictor_68_face_landmarks.dat"


# save frame 
def saveFrame(frame, number): 

            print sys.argv[2]+"/"+"{:.0f}".format(number*1000)+".jpg"

            height, width = frame.shape[:2]

            thumbnail = cv2.resize(frame, (width/2, height/2))

            cv2.imwrite(sys.argv[2]+"/"+"{:.0f}".format(number*1000)+".jpg", thumbnail)


# if the video is rotated, rotate the frame before processing 
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

        print ("Incorrect paramaeters")

        print sys.argv

        print ("Usage: python screenshots.py path/to/video /path/to/folder/screenshot angle")

        return

    video_capture = cv2.VideoCapture(sys.argv[1])

    if is_cv3() : 

        fps = video_capture.get(cv2.CAP_PROP_FPS)

    else : 

        fps = video_capture.get(cv2.cv.CV_CAP_PROP_FPS) 



    if os.path.exists(sys.argv[2]):


        shutil.rmtree(sys.argv[2])

        os.makedirs(sys.argv[2])

    else: 

        os.makedirs(sys.argv[2])

    rotation = sys.argv[3]

    last_frame_index = 0 

    file = open(sys.argv[2]+"/output.text", "w")

    file.writelines("fps:"+str(fps)+"\n")

    number_of_screenshot = 0 
    

    while True:
        # Capture frame-by-frame
        ret, frame = video_capture.read()

        if not ret: 

            break 

        frame = rotate_image_90(frame, int(rotation))


        if is_cv3() :

            current_frame_number = video_capture.get(cv2.CAP_PROP_POS_FRAMES)

        else:   

            current_frame_number = video_capture.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)


        height, width = frame.shape[:2]


        resized_image = cv2.resize(frame, (width/2, height/2))

        if current_frame_number == 1: 

            saveFrame(resized_image, 0)

            file.writelines(str(current_frame_number)+":"+str(number_of_screenshot)+".jpg\n")

            continue

        if current_frame_number - last_frame_index < SKIP_SECOND * fps: 

                continue

        if  current_frame_number - last_frame_index > MAX_SECOND * fps:


            saveFrame(frame, current_frame_number/float(fps))

            file.writelines(str(current_frame_number)+":"+str(number_of_screenshot)+".jpg\n")

            last_frame_index = current_frame_number

            continue




        gray = cv2.cvtColor(resized_image, cv2.COLOR_BGR2GRAY)

        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        clahe_image = clahe.apply(gray)

        detections = detector(clahe_image, 1) #Detect the faces in the image


        for k,d in enumerate(detections): #For each detected face
        
                shape = predictor(clahe_image, d) #Get coordinates
                point_list = []
                for i in range(60,68): #There are 68 landmark points on each face
                    
                    cv2.circle(resized_image, (shape.part(i).x, shape.part(i).y), 1, (0,0,255), thickness=2)

                    point_list.append(shape.part(i))

                if len(point_list) > 0:

                    distance = distance_to_line(point_list[2], point_list[0], point_list[4]) + distance_to_line(point_list[6], point_list[0], point_list[4])

                    ratio =  distance_line (point_list[2], point_list[6]) / distance_line(point_list[0], point_list[4])

                    # print ratio

                    if ratio > RATIO_THRESHOLD:

                        # cv2.putText(resized_image, 'Open', (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

                        saveFrame(frame, current_frame_number/float(fps))

                        file.writelines("{:.0f}".format(current_frame_number/float(fps)*1000)+".jpg\n")

                        last_frame_index = current_frame_number

                        continue


     


    file.close()

    video_capture.release()


main()
