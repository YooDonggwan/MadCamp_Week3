# #this program does the pitch shift to the record

# import pyaudio
# import wave
# import numpy as np
# from scipy.io import wavfile
# import pyrubberband as pyrb


# #http://people.csail.mit.edu/hubert/pyaudio/
# #special thanks to http://zulko.github.io/blog/2014/03/29/soundstretching-and-pitch-shifting-in-python/

# FORMAT = pyaudio.paInt16
# CHANNELS = 2
# RATE = 44100

# #work with one huge chunk
# CHUNK = 204800
# RECORD_SECONDS = 5
# WAVE_OUTPUT_FILENAME = "file.wav"

# audio = pyaudio.PyAudio()
 
# # start Recording
# stream = audio.open(format=FORMAT, channels=CHANNELS,
#                 rate=RATE, input=True,
#                 frames_per_buffer=CHUNK)
# print ("* recording")

# def stretch(snd_array, factor, window_size, h):
#     """ Stretches/shortens a sound, by some factor. """
#     phase = np.zeros(window_size)
#     hanning_window = np.hanning(window_size)
#     result = np.zeros(int(len(snd_array) / factor + window_size))
#     for i in np.arange(0, len(snd_array) - (window_size + h), h*factor):
#         i = int(i)
#         # Two potentially overlapping subarrays
#         a1 = snd_array[i: i + window_size]
#         a2 = snd_array[i + h: i + window_size + h]

#         # The spectra of these arrays
#         s1 = np.fft.fft(hanning_window * a1)
#         s2 = np.fft.fft(hanning_window * a2)

#         # Rephase all frequencies
#         phase = (phase + np.angle(s2/s1)) % 2*np.pi

#         a2_rephased = np.fft.ifft(np.abs(s2)*np.exp(1j*phase))
#         i2 = int(i/factor)
#         result[i2: i2 + window_size] += hanning_window*a2_rephased.real
#     return result.astype('int16')

# def speedx(sound_array, factor):
#     """ Multiplies the sound's speed by some `factor` """
#     indices = np.round( np.arange(0, len(sound_array), factor) )
#     indices = indices[indices < len(sound_array)].astype(int)
#     return sound_array[ indices.astype(int) ]

# def pitchshift(snd_array, n, window_size=2**13, h=2**11):
#     """ Changes the pitch of a sound by ``n`` semitones. """
#     factor = 2**(1.0 * n / 12.0)
#     stretched = stretch(snd_array, 1.0/factor, window_size, h)
#     return speedx(stretched[window_size:], factor)

# def playAudio(audio, samplingRate, channels):
#     p = pyaudio.PyAudio()
#     stream = p.open(format=pyaudio.paInt16,
#                     channels=channels,
#                     rate=samplingRate,
#                     output=True)
#     sound = (audio.astype(np.int16).tostring())
#     stream.write(sound)

#     stream.stop_stream()
#     stream.close()
#     p.terminate()
#     return

# data = stream.read(CHUNK)
# data = np.fromstring(data, dtype=np.int16)

# # fps, data = wavfile.read("sample1.wav")

# #make two times louder
# data *= 2

# print ("* done recording")

# # stop Recording
# stream.stop_stream()
# stream.close()
# audio.terminate()

# #Tests
# playAudio(data, RATE, CHANNELS)

# pitched = pitchshift(data, -5)
# playAudio(pitched, RATE, CHANNELS)

# pitched = pitchshift(data, 5)
# playAudio(pitched, RATE, CHANNELS)

# #save file
# waveFile = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
# waveFile.setnchannels(CHANNELS)
# waveFile.setsampwidth(audio.get_sample_size(FORMAT))
# waveFile.setframerate(RATE)
# waveFile.writeframes(data.tobytes()) #b''.join(data))
# waveFile.close()
# print('WAV file was saved as', WAVE_OUTPUT_FILENAME)


# import numpy as np
# from scipy.io import wavfile
# from pydub import AudioSegment


# def speedx(sound_array, factor):
#     """ Multiplies the sound's speed by some `factor` """
#     indices = np.round( np.arange(0, len(sound_array), factor) )
#     indices = indices[indices < len(sound_array)].astype(int)
#     return sound_array[ indices.astype(int) ]


# def stretch(sound_array, f, window_size, h):
#     """ Stretches the sound by a factor `f` """

#     phase  = np.zeros(window_size)
#     hanning_window = np.hanning(window_size)
#     result = np.zeros( int(len(sound_array) /f + window_size) )

#     for i in np.arange(0, len(sound_array)-(window_size+h), h*f):

#         i = int(i)

#         # two potentially overlapping subarrays
#         a1 = sound_array[i: i + window_size]
#         a2 = sound_array[i + h: i + window_size + h]

#         # resynchronize the second array on the first
#         # s1 =  np.fft.fft(hanning_window * a1)
#         # s2 =  np.fft.fft(hanning_window * a2)
#         s1 =  np.fft.fft(hanning_window * a1)
#         s2 =  np.fft.fft(hanning_window * a2)
#         phase = (phase + np.angle(s2/s1)) % 2*np.pi
#         a2_rephased = np.fft.ifft(np.abs(s2)*np.exp(1j*phase))

#         # add to result
#         i2 = int(i/f)
#         result[i2 : i2 + window_size] = np.add(result[i2 : i2 + window_size], hanning_window*a2_rephased, casting="unsafe")

#     result = ((2**(16-4)) * result/result.max()) # normalize (16bit)

#     return result.astype('int16')


# def pitchshift(snd_array, n, window_size=2**13, h=2**11):
#     """ Changes the pitch of a sound by ``n`` semitones. """
#     factor = 2**(1.0 * n / 12.0)
#     stretched = stretch(snd_array, 1.0/factor, window_size, h)
#     return speedx(stretched[window_size:], factor)


# fps, bowl_sound = wavfile.read("1234.wav")
# tones = range(-25,25)
# #transposed = [pitchshift(bowl_sound, n) for n in tones]

# transposed= []
# for n in tones:
#     pitch_shifted= []

#     # cycle through channels
#     for ch in range(bowl_sound.shape[1]):
#         sound_channel = bowl_sound[:, ch]
#         pitch_shifted.append(pitchshift(sound_channel, n))

#     # now that all channels are collected in a list
#     # combine into a single numpy array
#     transposed.append(np.transpose(np.array(pitch_shifted)).copy(order='C'))

# transposed = np.array(transposed)
# print(transposed.shape)
# track = AudioSegment.from_file('1234.wav')

# wavfile.write('asd.wav', 44100, transposed)


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