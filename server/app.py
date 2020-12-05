from flask import Flask, request, render_template, send_from_directory
import librosa
import numpy as np
from werkzeug.utils import secure_filename
from matplotlib import pyplot as plt
from scipy.signal import butter, lfilter, freqz
import pyrubberband as pyrb

app = Flask(__name__)

@app.route('/sound/<filename>', methods=['GET', 'POST'])
def download_file(filename):
    # filename = request.args.get('filename', "third.wav")
    print(filename)
    return send_from_directory("/home/dbehdrhks/mindonglody/sound/", filename)

@app.route('/sound2/<filename>', methods=['GET', 'POST'])
def download_file2(filename):
    # filename = request.args.get('filename', "third.wav")
    print(filename)
    return send_from_directory("/home/dbehdrhks/mindonglody/sound2/", filename)

@app.route('/pitch_shift', methods=['GET','POST'])
def get_wav():

    print('only connect')
    print(request)

    if request.form.get("method") == 'PUT':
        
        print('put connect')
        get_key1 = request.form.get("key1")
        get_key2 = request.form.get("key2")
        f = request.files['file']
        # filePath = "./" + secure_filename(f.filename)
        # f.save(filePath)

        print("1111")
        print(get_key1)
        # start~end 파일 잘라서 load에 넣기
        
        y, sr = librosa.load(f)
        
        
        y_third = librosa.effects.pitch_shift(y, sr, n_steps=get_key1)
        y_fifth = librosa.effects.pitch_shift(y, sr, n_steps=get_key2)

        #librosa.output.write_cd wav('orig.wav', (y_third_orig), sr)
        librosa.output.write_wav('../sound/' + f.filename, y + y_third, sr)
        librosa.output.write_wav('../sound2/' + f.filename, y + y_third + y_fifth*0.7, sr)

        
        return "success"

    return "failed"





if __name__ =='__main__':
    app.run(debug = True, host = '0.0.0.0', port = 7081)
    