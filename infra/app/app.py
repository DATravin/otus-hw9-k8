import os
import sys

#sys.path.append(os.getcwd())

from fastapi import FastAPI, status, HTTPException
from infrerence_app import predict
from fastapi.responses import Response

app = FastAPI()

@app.get("/")
def health_check() -> dict:
    """Health check"""
    return {"status": "ok"}

@app.get("/test")
def health_check() -> dict:
    """Health check"""
    return {"status test": "ok"}

@app.get(f'/health')
def health() -> Response:
  return Response(status_code=status.HTTP_200_OK)

@app.get(f'/ready')
def ready() -> Response:
  return Response(status_code=status.HTTP_200_OK)

@app.get(f'/startup')
def startup() -> Response:
  return Response(status_code=status.HTTP_200_OK)

@app.get("/predict")
def make_prediction() -> dict:
    """inference model"""

    predict_prob = predict()

    return {"prob": predict_prob}
