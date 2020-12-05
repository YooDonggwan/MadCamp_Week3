
import librosa
import numpy as np
from matplotlib import pyplot as plt
from scipy.signal import butter, lfilter, freqz
import pyrubberband as pyrb



def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a


def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y



y, sr = librosa.load('do.wav')
#y_third_orig = librosa.effects.pitch_shift(y, sr, n_steps=-4)
y_stretch = pyrb.time_stretch(y, sr, 2.0)
# y_t = butter_bandpass_filter(y, 200.0, 400.0, sr, order=3)
# y_test = np.zeros(len(y))
y_third = librosa.effects.pitch_shift(y_stretch, sr, n_steps=4)
#y_fifth = librosa.effects.pitch_shift(y, sr, n_steps=7)
#librosa.output.write_wav('orig.wav', (y_third_orig), sr)
librosa.output.write_wav('third.wav', y_third, sr)
# librosa.output.write_wav('out.wav', y, sr)
# librosa.output.write_wav('out.wav', y_third, sr)