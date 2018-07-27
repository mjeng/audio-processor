from flask import Flask, request, render_template
import emily_script

app = Flask(__name__)

@app.route("/process_audio", methods=['POST'])
def homepage():
    print(request)
    # if request.method == 'POST' and 'file' in request.files:
    if request.method == "POST":
        # audio_file = request.files['audio_file']
        # emily_script.process_file(audio_file)
        return "Hello"
    else:
        print("??")


if __name__ == "__main__":
    app.run(debug=True, port=5000)
