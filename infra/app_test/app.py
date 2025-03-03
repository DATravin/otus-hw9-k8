"""
Application
"""

import os

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from fastapi import FastAPI, status


app = FastAPI()


@app.get("/")
def health_check() -> dict:
    """Health check"""
    return {"status": "ok"}

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
    """Make a prediction by model"""
    pred_class = 'bingo'
    
    return {"prediction": pred_class}