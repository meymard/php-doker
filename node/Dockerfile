FROM node

RUN apt-get update && apt-get install -y bash

RUN groupadd meymard
RUN useradd -m -g meymard meymard

RUN mkdir /node-app

WORKDIR /node-app
