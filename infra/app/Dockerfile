FROM ubuntu:22.04


# install packages
RUN apt-get update && \
    apt-get install -y curl \
    wget \
    openjdk-8-jdk

RUN apt-get install -y build-essential python3-pip
RUN pip3 -q install pip --upgrade

WORKDIR /app

COPY . .

USER root

RUN pip install --no-cache-dir -r requirements.txt
#RUN pip install -U -e .
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chmod +x entrypoint.sh

CMD ["bash", "entrypoint.sh"]
