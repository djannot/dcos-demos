FROM tensorflow/tensorflow:1.9.0
RUN pip install confluent-kafka
RUN pip install Flask
RUN pip install flickrapi
ADD serve-model.py /
ADD output_labels.txt /
ADD output_graph.pb /
ADD templates/main.html /templates/main.html
ADD templates/response.html /templates/response.html
RUN mkdir /static
WORKDIR /
