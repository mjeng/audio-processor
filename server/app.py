from flask import Flask, request, render_template, send_file
# import emily_script

app = Flask(__name__)

@app.route("/", methods=['GET'])
def homepage():
    return "insert server here"

@app.route("/process_audio", methods=['POST'])
def process_audio():
    print(request)
    # if request.method == 'POST' and 'file' in request.files:
    if request.method == "POST":
        # audio_file = request.files['audio_file']
        # emily_script.process_file(audio_file)
        return "Hello"
    else:
        print("??")

@app.route("/test_page", methods=['GET', 'POST'])
def test():
    if request.method == 'GET':
        return "GET successful"
    elif request.method == 'POST':
        return send_file("ice-cream.jpg")

if __name__ == "__main__":
    app.run(debug=True, port=5000)
