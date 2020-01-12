import librosa
import numpy as np
from matplotlib import pyplot as plt
from scipy.signal import butter, lfilter, freqz
import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as sig



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

###################

def toHz(value):
    from numpy import pi
    return value/2/pi
    
def direct2FormModel(data, a1, a2, b0, b1, b2):
    from numpy import zeros, arange
    
    result = zeros((len(data),))
    timeZone = zeros((len(data),))
    
    for n in arange(2, len(data)):
        sum0 = -a1*timeZone[n-1] - a2*timeZone[n-2]
        timeZone[n] = data[n] + sum0
        result[n] = b0*timeZone[n] + b1*timeZone[n-1] + b2*timeZone[n-2]
        
    return result
    
def differentialEqForm(data, a1, a2, b0, b1, b2):
    from numpy import zeros, arange
    
    result = zeros((len(data),))
    
    for n in arange(2, len(data)):
        result[n] = b0*data[n] + b1*data[n-1] + b2*data[n-2] - a1*result[n-1] - a2*result[n-2]
        
    return result
    
def draw_FFT_Graph(data, fs, **kwargs):
    from numpy.fft import fft
     
    graphStyle = kwargs.get('style', 0) #kwargs = keyword arguments
    xlim = kwargs.get('xlim', 0)
    ylim = kwargs.get('ylim', 0)
    title = kwargs.get('title', 'FFT result')
    
    n = len(data)
    k = np.arange(n)
    T = n/fs
    freq = k/T 
    freq = freq[range(int(n/2))]
    FFT_data = fft(data)/n 
    FFT_data = FFT_data[range(int(n/2))]
    
    plt.figure(figsize=(12,5))
    if graphStyle == 0:
        plt.plot(freq, abs(FFT_data), 'r', linestyle=' ', marker='^') 
    else:
        plt.plot(freq,abs(FFT_data),'r')
    plt.xlabel('Freq (Hz)')
    plt.ylabel('|Y(freq)|')
    plt.vlines(freq, [0], abs(FFT_data))
    plt.title(title)
    plt.grid(True)
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.show()



# Create Test Signal
Fs = 20*10**3               # 20kHz
Ts = 1/Fs                   # sample Time
endTime = 2
t = np.arange(0.0, endTime, Ts)

inputSig = 3.*np.sin(2.*np.pi*500.*t)

sampleFreq = np.arange(50,1000,50)

for freq in sampleFreq:
    inputSig = inputSig + 2*np.sin(2*np.pi*freq*t)
    
plt.figure(figsize=(12,5))
plt.plot(t, inputSig)
plt.xlabel('Time(s)')
plt.title('Test Signal in Continuous')
plt.grid(True)
plt.show()

draw_FFT_Graph(inputSig, Fs, title='inputSig', xlim=(0, 1200))

# Band Pass Filter in Continuous Time
f_peak = 500
w0_peak = 2*np.pi*f_peak
bandWidth = 200
Q = f_peak/bandWidth
H = 1/w0_peak
H0 = H/Q

num = np.array([H0*w0_peak**2, 0])
den = np.array([1, w0_peak/Q, w0_peak**2])

w, h = sig.freqs(num, den, worN=np.logspace(0, 5, 1000))

plt.figure(figsize=(12,5))
plt.semilogx(toHz(w), 20 * np.log10(abs(h)))
plt.axvline(f_peak, color='k', lw=2)
plt.axvline(f_peak-bandWidth/2, color='k', lw=1)
plt.axvline(f_peak+bandWidth/2, color='k', lw=1)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude response [dB]')
tmpTitle = 'Band Pass Filter, Peak freq. at ' + str(f_peak) + 'Hz in continuous'
plt.title(tmpTitle)
plt.xlim((f_peak-bandWidth/2)*0.1, (f_peak+bandWidth/2)*10)
plt.grid()
plt.show()

numz, denz = sig.bilinear(num, den , Fs)

wz, hz = sig.freqz(numz, denz, worN=10000)

numz1 = np.array([2*H0*w0_peak**2/Ts, 0, 
                  -2*H0*w0_peak**2/Ts])
denz1 = np.array([4/Ts**2+2*w0_peak/Q/Ts+w0_peak**2, 
                  -8/Ts**2+2*w0_peak**2, 
                  4/Ts**2-2*w0_peak/Q/Ts+w0_peak**2])

numz1 = numz1/denz1[0]
denz1 = denz1/denz1[0]

wz1, hz1 = sig.freqz(numz1, denz1, worN=10000)

plt.figure(figsize=(12,5))
plt.semilogx(toHz(w), 20 * np.log10(abs(h)), label='continuous')
plt.semilogx(toHz(wz*Fs), 20 * np.log10(abs(hz)), 'c', label='discrete')
plt.semilogx(toHz(wz1*Fs), 20 * np.log10(abs(hz1)), 'r', label='discrete')
plt.axvline(f_peak, color='k', lw=2)
plt.axvline(f_peak-bandWidth/2, color='k', lw=1)
plt.axvline(f_peak+bandWidth/2, color='k', lw=1)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude response [dB]')
tmpTitle = 'Band Pass Filter, Peak freq. at ' + str(f_peak) + 'Hz in discrete'
plt.title(tmpTitle)
plt.xlim((f_peak-bandWidth/2)*0.02, (f_peak+bandWidth/2)*50)
plt.legend()
plt.grid()
plt.show()

filteredOut = direct2FormModel(inputSig, denz[1], denz[2], numz[0], numz[1], numz[2])

draw_FFT_Graph(filteredOut, Fs, xlim=(0, 1200))

plt.figure(figsize=(12,5))
plt.plot(t, inputSig, label='inputSig')
plt.plot(t, filteredOut, 'r', label='filteredOut')
plt.xlabel('Time(s)')
plt.legend()
plt.grid(True)
plt.show()