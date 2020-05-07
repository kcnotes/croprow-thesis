from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, Dense, Dropout
from keras.layers import Activation, Flatten, Lambda, Input, ELU
from keras.optimizers import Adam, SGD
from keras.utils import np_utils
from keras.preprocessing.image import ImageDataGenerator
import keras.backend as K

# Accuracy to .01 degree
def accurate_point_001(y_true, y_pred):
    diff = K.abs(y_true-y_pred)       # absolute difference between true and prediction
    correct = K.less(diff,0.001)   # difference less than .001
    return K.mean(correct)            # mean of correct

# Accuracy to .1 degree
def accurate_point_01(y_true, y_pred):
    diff = K.abs(y_true-y_pred)
    correct = K.less(diff,0.01)
    return K.mean(correct)

# Accuracy to 1 degree
def accurate_point_1(y_true, y_pred):
    diff = K.abs(y_true-y_pred)
    correct = K.less(diff,0.1)
    return K.mean(correct)

# Keras implementation for 2D depth image
def model(input_shape):
    model = Sequential()

    # Input normalisation layer
    # model.add(Lambda(lambda x: x /127.5 - 1.))
    model.add(Conv2D(24, (5,5), activation='relu', input_shape=input_shape))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    # Second layer
    model.add(Conv2D(36, (5,5), activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    # Three fully connected layers
    model.add(Flatten())
    model.add(Dense(1024, activation='relu'))
    model.add(Dropout(0.1))
    model.add(Dense(512, activation='relu'))
    model.add(Dense(100, activation='relu'))
    model.add(Dense(10, activation='relu'))
    # Output control value, linear for negative angles
    model.add(Dense(1, activation='tanh'))

    sgd = SGD(lr=0.0001, decay=1e-6, momentum=0.9, nesterov=True)
    # adam = Adam(lr=0.001)
    model.compile(optimizer=sgd, loss='mse', metrics=[accurate_point_001, accurate_point_01, accurate_point_1])

    return model