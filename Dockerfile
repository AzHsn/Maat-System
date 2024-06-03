FROM python:3.11

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# set default shell
SHELL [ "/bin/bash", "-c" ]

RUN mkdir /app

WORKDIR /app

RUN apt update && apt upgrade -y

COPY . /app/
# install required packages
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 80
CMD ["gunicorn", "project.wsgi", "--bind", "0.0.0.0:80"]