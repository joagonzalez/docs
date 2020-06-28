FROM python:3.7

COPY ./newcos/ /newcos/
COPY ./requirements.txt /newcos/

WORKDIR /newcos/
RUN ls
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["mkdocs", "serve"]