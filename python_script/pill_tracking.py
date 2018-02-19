import cv2
import sys
import numpy as np
import dlib
import math


# this script uses Face Landmark Detection - Dlib to detect 8 points in the mouth
# it then calculates the ratio between distance of the upper point and lower point and distance of leftmost point and rightmost point
# threshold to check if the mouth is open, if the ratio > RATIO_THRESHOLD, the mouth is open 
# reference: http://www.pyimagesearch.com/2017/04/03/facial-landmarks-dlib-opencv-python/

RATIO_THRESHOLD = 0.21

vout = cv2.VideoWriter()

DEBUG = False 

pill_rect = None        # position of the pill area 
upper_pill_color = None # upper color of the pill in hsv space
lower_pill_color = None # lower color of the pill in hsv space

# #http://docs.opencv.org/3.0-beta/doc/py_tutorials/py_imgproc/py_colorspaces/py_colorspaces.html


global_list = []
mouth_list = []

global start_tracking

detector = dlib.get_frontal_face_detector()

predictor = dlib.shape_predictor("/app/.heroku/vendor/openface/models/dlib/shape_predictor_68_face_landmarks.dat")


def is_cv3():

    return cv2.__version__.startswith("3.")


def distance_to_line(p, p1, p2):
        x_diff = p2.x - p1.x
        y_diff = p2.y - p1.y
        num = abs(y_diff*p.x - x_diff*p.y + p2.x*p1.y - p2.y*p1.x)
        den = math.sqrt(y_diff**2 + x_diff**2)
        return num / den

def distance_line (p1, p2):

    return math.sqrt( (p1.x - p2.x)**2 + (p1.y - p2.y)**2 )


    
# check if two rectangle overlap 
def isRectanglesOverlap(rect1,rect2):
    x1,y1,w1,h1 = rect1
    x2,y2,w2,h2 = rect2
    for i in range(w1):
        for j in range(h1):
            x = x1+i
            y = y1+j
            if(x<=x2+w2 and x>=x2 and y<=y2+h2 and y>=y2):
                return True
    #print "con:",rect1,"pill:",rect2
    return False

# check if a contour overlaps with a rectangle
def isContourOverlapRectangle(contour, rect): 

    bounding_rect = cv2.boundingRect(contour)

    return isRectanglesOverlap (bounding_rect, rect)


# check if a rectangle overlaps with global_list of contour

def isRectangleOverlapGlobalContour(rect):

    for rect2 in global_list_rect: 

        if isRectanglesOverlap(rect2, rect): 

            return True

    return False

# check if a contour overlap global_list of contour

def isOverLapGlobalContour ( ct): 

    rect = cv2.boundingRect(ct)

    if len(global_list) == 0: 

        return False

    for contour in global_list[-1]:

        temp = cv2.boundingRect(contour)

        if isRectanglesOverlap(temp, rect): 

            return True

    return False
        
    

def rotate_image_90(im, angle):
    if angle % 90 == 0:
        angle = angle % 360
        if angle == 0:
            return im
        elif angle == 90:
            return im.transpose((1,0, 2))[:,::-1,:].astype(np.uint8).copy() 
        elif angle == 180:
            return im[::-1,::-1,:].astype(np.uint8).copy()
        elif angle == 270:
            return im.transpose((1,0, 2))[::-1,:,:].astype(np.uint8).copy() 

    else:
        raise Exception('Error')

def main(argv):
    if len(argv) != 5:
        print "Incorrect parameters"
        print "Usage: python pill_tracking.py path/to/video rotation pill_rect upper_color lower_color"
        print "Example: python pill_tracking.py data/video8.mov 90 \"(10,900,200,200)\" \"(30 ,255 ,255)\" \"(20, 100, 100)\""
        return

    cap = cv2.VideoCapture(argv[0])

    if is_cv3(): 
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        fps = int(cap.get(cv2.CAP_PROP_FPS))
        frameCount = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    else: 

        width = int(cap.get(cv2.cv.CV_CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.cv.CV_CAP_PROP_FRAME_HEIGHT))

        fps = int(cap.get(cv2.cv.CV_CAP_PROP_FPS))
        frameCount = int(cap.get(cv2.cv.CV_CAP_PROP_FRAME_COUNT))




    size = (int(height)), int(width)

    fps = 20
    fourcc = cv2.VideoWriter_fourcc('m', 'p', '4', 'v') # note the lower case

    if DEBUG: 

        vout = cv2.VideoWriter()
        vout.open('/Users/dungnt/Documents/Repository/soc-work/data/output2.mp4',fourcc,fps,size,True) 

    start_tracking = False
    is_mouth_open = False
    mouth_rect = None


    rotation = argv[1]
    array = argv[2][1:-1].split(",")
    
    pill_rect = (int(array[0]), int(array[1]), int(array[2]), int(array[3]))

    array = argv[3][1:-1].split(",")

    upper_pill_color = (int(array[0]), int(array[1]), int(array[2]))

    array = argv[4][1:-1].split(",")

    lower_pill_color = (int(array[0]), int(array[1]), int(array[2]))

    while True: 

        grabbed, img = cap.read()

        if not grabbed:
            break

        if DEBUG: 

            print "#frame"

        img = rotate_image_90(img, int(rotation))


        height, width = img.shape[:2]

        # img = cv2.resize(img, (width/2, height/2))


        if start_tracking: 

                # check if the mouth is open or close 

                gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
                clahe_image = clahe.apply(gray)

                detections = detector(clahe_image, 1) #Detect the faces in the image

                for k,d in enumerate(detections): #For each detected face
                    
                    shape = predictor(clahe_image, d) #Get coordinates
                    point_list = []
                    for i in range(60,68): #There are 68 landmark points on each face

                        if DEBUG: 
                        
                            cv2.circle(img, (shape.part(i).x, shape.part(i).y), 1, (0,0,255), thickness=2)

                        point_list.append(shape.part(i))

                    if len(point_list) > 0:

                        distance = distance_to_line(point_list[2], point_list[0], point_list[4]) + distance_to_line(point_list[6], point_list[0], point_list[4])

                        ratio =  distance_line (point_list[2], point_list[6]) / distance_line(point_list[0], point_list[4])

                        mouth_rect = (point_list[0].x, point_list[2].y, point_list[4].x - point_list[0].x, point_list[6].y - point_list[2].y)

                        if DEBUG: 

                            cv2.rectangle(img, (mouth_rect[0], mouth_rect[1]), (mouth_rect[0] + mouth_rect[2], mouth_rect[1] + mouth_rect[3]), (0,0,255), thickness=2)


                        if ratio > RATIO_THRESHOLD :

                            is_mouth_open = True




                            if DEBUG: 

                                cv2.putText(img, 'Open', (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

                        else: 

                            is_mouth_open = False






        cv2.rectangle(img, (pill_rect[0], pill_rect[1]), (pill_rect[0]+pill_rect[2], pill_rect[1]+pill_rect[3]), (0, 0, 255), 2)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)


        pill_color_mask = cv2.inRange(hsv, lower_pill_color, upper_pill_color)

        # pill_color_mask = cv2.erode(pill_color_mask, None, iterations=2)

        dilation = np.ones((5, 5), "uint8")

        pill_color_mask = cv2.dilate(pill_color_mask, dilation)

        _, contours, hierarchy = cv2.findContours(pill_color_mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

        pill_con = None
        max_area = 10

        sub_contours = []



        for idx, contour in enumerate(contours):
            con_area = cv2.contourArea(contour)
            con_rect = cv2.boundingRect(contour)

            # print con_area



            if start_tracking and con_area > max_area: 

                # check if this contour overlaps with previous contour


                if isOverLapGlobalContour(contour): 

                    sub_contours.append(contour)

                    # check if pill into the open mouth 

                    if (is_mouth_open and isContourOverlapRectangle(contour, mouth_rect)): 


                        print "true"



                        return 1


                    if DEBUG: 

                        cv2.drawContours(img, contour, -1, (0, 255, 0), 3)



            


            # check if a contour overlaps with pill area 

            if(isRectanglesOverlap(con_rect,pill_rect)) :
                if con_area > max_area:
                    pill_con = contour

                    start_tracking = True

                    if DEBUG: 

                        print "start tracking"
    
                    sub_contours.append(contour)

        global_list.append(sub_contours)

                    

        for contours in [global_list[-1]]: 

            for ct in contours: 

                contour = cv2.boundingRect(ct)

                


        if DEBUG : 

            height, width = img.shape[:2]

            resized_image = cv2.resize(img, (width/2, height/2))

            vout.write(img)

            cv2.imshow("image", resized_image)

            
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
               break



if __name__ == "__main__":
    main(sys.argv[1:])