FROM python:3.6.1-alpine  

RUN pip install --upgrade pip 

WORKDIR /app

ADD . /app 

RUN pip install -r requirements.txt

CMD ["python", "app.py"]