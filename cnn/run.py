import numpy as np
import pickle
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle
from model import model
from keras.utils import print_summary
from keras.callbacks import ModelCheckpoint, TensorBoard
from keras.preprocessing.image import ImageDataGenerator

def main():
    # Load features and labels
    with open("features.pickle", "rb") as f:
        features = np.array(pickle.load(f))[:800]
    with open("labels.pickle", "rb") as f:
        labels = np.array(pickle.load(f))[:800]

    # Shuffle
    features, labels = shuffle(features, labels)

    # Don't perform augmentation - can cause problems with determining angle
    
    # split training, testing sets
    train_x, test_x, train_y, test_y = train_test_split(features, labels, random_state=0,
                                                        test_size=0.3)
    train_x = train_x.reshape(train_x.shape[0], 132, 176, 1)
    test_x = test_x.reshape(test_x.shape[0], 132, 176, 1)
    print(train_x[0].shape)

    # Generate the DriveNet model
    nn = model((132, 176, 1))

    checkpoint = ModelCheckpoint('model.h5', verbose=1, save_best_only=True)
    tensorboard_callback = TensorBoard(log_dir='checkpoints', histogram_freq=1)

    # Run the training
    nn.fit(train_x, train_y, validation_data=(test_x, test_y), epochs=250, batch_size=64, callbacks=[checkpoint, tensorboard_callback])

    print_summary(nn)
    nn.save('model.h5')

main()