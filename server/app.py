from flask import Flask, request
import apicall
import librosa
import numpy as np
from werkzeug import secure_filename
from matplotlib import pyplot as plt
from scipy.signal import butter, lfilter, freqz

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello minsu"

@app.route('/pitch_shift', methods=['GET','POST'])
def get_wav():

    print('only connect')
    print(request)

    if request.form.get("method") == 'PUT':
        # starting_point = request.form.get("start")
        # end_point = request.form.get("end")
        print('put connect')
        get_key1 = request.form.get("key1")
        get_key2 = request.form.get("key2")
        f = request.files['file']
        filePath = "./" + secure_filename(f.filename)
        f.save(filePath)

        # start~end 파일 잘라서 load에 넣기
        # 화음 종류 선택할 수 있게 하기? - for문 돌려서 리스트에 넣을 수 있게
        
        y, sr = librosa.load(secure_filename(f.filename))
        # y_third_orig = librosa.effects.pitch_shift(y, sr, n_steps=-4)
        # y_t = apicall.butter_bandpass_filter(y, 200.0, 400.0, sr, order=3)
        y_third = librosa.effects.pitch_shift(y, sr, n_steps=4)
        y_fifth = librosa.effects.pitch_shift(y, sr, n_steps=get_key2)
        #librosa.output.write_cd wav('orig.wav', (y_third_orig), sr)
        librosa.output.write_wav('third.wav', y + y_third, sr)
        # librosa.output.write_wav('out.wav', y, sr)
        # librosa.output.write_wav('out.wav', y_third, sr)
        return "success"

    return "failed"





if __name__ =='__main__':
    app.run(debug = True, host = '0.0.0.0', port = 7081)
    # app.run(debug = True, port = 4001)
    # app.run()