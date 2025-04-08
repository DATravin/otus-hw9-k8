FROM python:3.11.4-slim-buster

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

RUN chmod +x entrypoint.sh

CMD ["bash", "entrypoint.sh"]