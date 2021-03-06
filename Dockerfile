FROM python:3.7

COPY ./docs/ /docs/
COPY ./requirements.txt /docs/

WORKDIR /docs/
RUN ls
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["mkdocs", "serve"]