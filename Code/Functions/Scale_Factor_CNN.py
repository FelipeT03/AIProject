# -*- coding: utf-8 -*-
"""
Felipe Toscano
09/09/2020
Uso de la red entrenada para la detección de dígitos
"""

import tensorflow as tf
from scipy.io import loadmat
import numpy as np
import pathlib
import os

model = tf.keras.models.load_model(os.path.join(pathlib.Path(__file__).parent.absolute(), "ModelScaleFactor"))

number = loadmat('ruler_number.mat')
number = number['ruler_number']


for k in range(len(number[0, 0])):
    number_analysis = number[:, :, k]
    number_analysis = number_analysis[..., np.newaxis]
    number_analysis = tf.image.resize(number_analysis, [28, 28])
    number_analysis = number_analysis[np.newaxis, ...]
    prediction = model.predict(number_analysis)
    print(np.argmax(prediction))
