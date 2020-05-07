# %%
from keras.models import load_model
from keras import models
from model import accurate_point_001, accurate_point_01, accurate_point_1
from sim_data_to_pickle import read_and_process
import matplotlib.pyplot as plt
import numpy as np
import pickle
import time

b_model = load_model('model.h5', custom_objects={
    "accurate_point_001": accurate_point_001, 
    "accurate_point_01": accurate_point_01, 
    "accurate_point_1": accurate_point_1
})

print(b_model.summary())

# %%
with open("sim_labels.pickle", "rb") as f:
    labels = np.array(pickle.load(f))

# %%
with open("sim_labels.pickle", "rb") as f:
    labels = np.array(pickle.load(f))
with open("sim_features.pickle", "rb") as f:
    features = np.array(pickle.load(f))

# %%
image = features[90]
prediction = b_model.predict(np.reshape(image, (1, 264//2, 352//2, 1)))
print("Prediction:", np.rot90(prediction)[0] * 180 - 90)
print("Actual:", labels[90] * 180 - 90)

# %% 
start = 2000
end = start + 20

images = []
for test_item in range(start, end):
    image = read_and_process('../simulation-dataset/dataset/' + str(test_item) + '.txt')
    # print(labels[test_item] * 180 - 90)
    # start_time = time.time()
    image = np.reshape(image, (264//2, 352//2))
    image = image / 7000
    image = np.reshape(image, (264//2, 352//2, 1))
    images.append(image)

prediction = b_model.predict(np.reshape(images, (20, 264//2, 352//2, 1)))
print(prediction)
    # print("--- %s seconds ---" % (time.time() - start_time))
# prediction = (prediction*180-90)*6.8
# print(prediction)
# print(np.min(prediction*180-90)*6.5, np.max(prediction*180-90)*6.5)
print("Prediction:", np.rot90(prediction)[0] * 180 - 90)
print("Actual:", labels[start-1:end-1] * 180 - 90)

# %% 

image_num = 10  q
show_image = images[image_num]
print("Prediction:", np.rot90(prediction)[0][image_num] * 180 - 90)
print("Actual:", labels[start-1+image_num] * 180 - 90)
# print(labels[start - 1] * 180 - 90)
show_image = np.reshape(show_image, (264//2, 352//2))
# plt.imshow(np.rot90(show_image))
plt.matshow(np.rot90(show_image), cmap=plt.cm.binary)
# plt.matshow(np.rot90(np.reshape(images[1], (264//2, 352//2))), cmap='viridis')
# plt.matshow(np.rot90(np.reshape(images[2], (264//2, 352//2))), cmap='viridis')
# plt.matshow(np.rot90(np.reshape(images[3], (264//2, 352//2))), cmap='viridis')
# plt.matshow(np.rot90(np.reshape(images[4], (264//2, 352//2))), cmap='viridis')
# plt.matshow(np.rot90(np.reshape(images[5], (264//2, 352//2))), cmap='viridis')


layer_outputs = [layer.output for layer in b_model.layers[:12]]
activation_model = models.Model(inputs=b_model.input, outputs=layer_outputs) # Creates a model that will return these outputs, given the model input
activations = activation_model.predict(np.reshape(show_image, (1, 264//2, 352//2, 1)))
# print(len(activations))
activation_0 = activations[0]
activation_1 = activations[1]
# activation_2 = activations[2]
# activation_3 = activations[3]
# activation_4 = activations[4]
# activation_5 = activations[5]
# activation_6 = activations[6]
# activation_7 = activations[7]
# activation_8 = activations[8]
# activation_9 = activations[9]
plt.matshow(np.rot90(activation_1[0, :, :, 5]), cmap=plt.cm.binary)
# for i in range(0, 24):
#     plt.matshow(np.rot90(activation_1[0, :, :, i]), cmap=plt.cm.binary)
# # plt.matshow(np.rot90(activation_2[0, :, :, 4]), cmap='viridis')
# plt.matshow(np.rot90(activation_3[0, :, :, 4]), cmap='viridis')
# # plt.matshow(np.rot90(activation_4[0, :, :, 4]), cmap='viridis')
# plt.matshow(np.rot90(activation_5[0, :, :, 4]), cmap='viridis')
# # plt.matshow(np.rot90(activation_6[0, :, :, 4]), cmap='viridis')
# plt.matshow(np.rot90(activation_7[0, :, :, 4]), cmap='viridis')
# # plt.matshow(np.rot90(activation_8[0, :, :, 4]), cmap='viridis')
# # print(activations[9][0])
# # plt.matshow((np.rot90(np.reshape(activations[5][0], (32, 32)))))
# # plt.matshow((np.rot90(np.reshape(activations[7][0], (16, 32)))))


# output = 0
# # Creates a model that will return these outputs, given the model input

# # print(b_model.summary())
