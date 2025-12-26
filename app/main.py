from fastapi import FastAPI, HTTPException, Response
import mlflow.pyfunc
import os
try:
    from app.schema import UnifiedFeatureSchema
    SCHEMA_AVAILABLE = True
except ImportError:
    SCHEMA_AVAILABLE = False
    from pydantic import BaseModel
    class UnifiedFeatureSchema(BaseModel):
        text: str
        @classmethod
        def validate_against_training_distribution(cls, text: str):
            if not (10 <= len(text) <= 500):
                raise ValueError("Text length must be between 10 and 500 characters.")
            return True
import logging
from collections import deque
import time
import logging
from collections import deque
import time

app = FastAPI(title="Sentiment Analysis MaaS", description="Model as a Service for sentiment analysis")

# Global deque to track confidence scores with timestamps for 5-minute rolling average
confidence_scores = deque()

# Model version
model_version = "mock-model"

# Get Git SHA from environment
git_sha = os.environ.get("GIT_SHA", "unknown")

@app.post("/analyze")
async def analyze_sentiment(request: UnifiedFeatureSchema, response: Response):
    # For now, return mock response to test the API
    sentiment = "POSITIVE" if "love" in request.text.lower() else "NEGATIVE"
    confidence = 0.9
    
    # Track for rolling average
    current_time = time.time()
    confidence_scores.append((current_time, confidence))
    
    # Remove scores older than 5 minutes
    while confidence_scores and current_time - confidence_scores[0][0] > 300:
        confidence_scores.popleft()
    
    # Calculate 5-minute rolling average
    if confidence_scores:
        avg_confidence = sum(score for _, score in confidence_scores) / len(confidence_scores)
        if avg_confidence < 0.6:
            logging.warning("Low Confidence Warning: 5-minute rolling average confidence dropped below 60%")
    
    # Add metadata response headers
    response.headers["X-Model-Version"] = model_version
    response.headers["X-Git-SHA"] = git_sha
    
    return {"sentiment": sentiment, "confidence": confidence}