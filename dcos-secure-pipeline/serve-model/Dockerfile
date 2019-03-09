FROM tensorflow/tensorflow:1.9.0
RUN pip install Flask
ADD serve-model.py /
ADD output_labels.txt /
ADD output_graph.pb /
ADD templates/response.html /templates/response.html
RUN mkdir /static
