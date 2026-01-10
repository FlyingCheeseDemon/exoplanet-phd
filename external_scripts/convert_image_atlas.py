import numpy as np
import cv2
from matplotlib import pyplot as plt

base_path = "/media/flyingdemon/Data2/Software/exoplanet-phd/assets/dual_tilemaps/"
atlas_name = "test_tilemap"
image = cv2.imread(base_path + atlas_name + ".png",cv2.IMREAD_UNCHANGED)
# plt.imshow(image)
# plt.show()

def rotate_image(image, angle):
    image_center = tuple(np.array(image.shape[1::-1]) / 2)
    rot_mat = cv2.getRotationMatrix2D(image_center, angle, 1.0)
    result = cv2.warpAffine(image, rot_mat, image.shape[1::-1], flags=cv2.INTER_LINEAR)
    return result

margin = np.array([12,12])
image_size = np.array([174,200])

new_image = np.zeros_like(image)

for angle in range(6):
    for j in range(1):
        for i in range(11):
            offset = np.array([j,i])
            image_start = margin+offset*image_size
            subimage = image[image_start[0]:image_start[0]+image_size[0],image_start[1]:image_start[1]+image_size[1]]
            subimage = rotate_image(subimage,angle*60)
            new_image[image_start[0]:image_start[0]+image_size[0],image_start[1]:image_start[1]+image_size[1]] = subimage
            
    plt.imshow(new_image)
    plt.show()
    cv2.imwrite(base_path + atlas_name + f"{angle}.png",new_image)
