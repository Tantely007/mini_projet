FROM python:3.7
RUN useradd flask
WORKDIR /home/flask
COPY . .
RUN pip install -r requirements.txt
RUN chmod a+x app.py test.py && chown -R flask:flask ./
ENV FLASK_APP app.py
EXPOSE 5000
USER flask
CMD ["./app.py"]