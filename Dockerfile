FROM python:3.7

COPY ./newcos/ /newcos/
WORKDIR /newcos/
RUN ls
RUN pip install mkdocs
EXPOSE 8000
CMD ["mkdocs", "serve"]