import numpy as np
import os
import pickle

def read_and_process(filename):
	i = 72 - 12
	j = 0
	image = []
	with open(filename, 'rb') as logfile:
		data = logfile.read()

		while i < 46536 - 12:
			image.append(data[i] + data[i + 1] * 256)
			j = j + 1
			i = i + 2
	return image

# Relies on Hough transform results
# since MPU results were bad
def get_labels(file):
    data = []
    with open(file, 'r') as label_file:
        data = label_file.readlines()
    data = ''.join(data).split('\n')
    data = [float(i) / 180.0 for i in data] 
    return data

def get_all_images(folder):
    images = []
    logs = os.listdir('../' + folder)
    for log in logs:
        if log.endswith('.log'):
            image = read_and_process('../' + folder + '/' + log)
            image = np.reshape(image, (264//2, 352//2))
            image[image > 8000] = 8000
            # Normalisation
            # print(np.linalg.norm(image))
            # print(max(image))
            image = image / np.linalg.norm(image)
            images.append(image)
            print(len(images))
    return images

labels = get_labels('../path-to/dataset/dataset-values.txt')
features = get_all_images('path-to/dataset')

features = np.array(features).astype(np.float32)
labels = np.array(labels).astype(np.float32)

with open("features.pickle", "wb") as f:
    pickle.dump(features, f)
with open("labels.pickle", "wb") as f:
    pickle.dump(labels, f)
