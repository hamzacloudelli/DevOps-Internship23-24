# app.py
from flask import Flask           # import flask
from flask import render_template
app = Flask(__name__)             # create an app instance

@app.route("/")                   # at the end point /
def hello():                      # call method hello
    return render_template('index.html')       # which returns "hello world"
if __name__ == "__main__":        # on running python app.py
    app.run(debug=True,host='0.0.0.0')                     # run the flask app