from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import pandas as pd
import numpy as np
import joblib
import os

app = FastAPI(title="NirSisa API")

# Path setup untuk model dan data
# Mengambil path absolut agar tidak error saat dideploy di Docker/Railway
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(CURRENT_DIR, "ml_models")
DATA_PATH = os.path.join(CURRENT_DIR, "data")

# Load assets (model dan data)
try:
    vectorizer = joblib.load(os.path.join(MODEL_PATH, "tfidf_vectorizer.pkl"))
    tfidf_matrix = joblib.load(os.path.join(MODEL_PATH, "recipe_matrix.pkl"))
    df_recipes = joblib.load(os.path.join(DATA_PATH, "recipe_data.pkl"))
except Exception as e:
    print(f"Error loading models: {e}")

# Schema
class IngredientItem(BaseModel):
    name: str
    days_left: int

class RecommendRequest(BaseModel):
    ingredients: List[IngredientItem]

# Fungsi untuk menghitung SPI (Novelty NirSisa)
def calculate_spi(days_remaining, alpha=2.0):
    return 1 / ((days_remaining + 1) ** alpha)

@app.get("/")
def read_root():
    return {"status": "NirSisa Backend is Online"}

@app.post("/recommend")
def recommend(request: RecommendRequest):
    try:
        user_ingredients = [item.name for item in request.ingredients]
        inventory_expiry = {item.name: item.days_left for item in request.ingredients}
        
        # Menghitung Similarity Score
        user_input_text = ' '.join(user_ingredients)
        user_vector = vectorizer.transform([user_input_text])
        from sklearn.metrics.pairwise import cosine_similarity
        cos_sim = cosine_similarity(user_vector, tfidf_matrix).flatten()
        
        # Menghitung SPI Score (Novelty NirSisa)
        spi_scores = np.zeros(len(df_recipes))
        for ingredient, days in inventory_expiry.items():
            urgency_score = calculate_spi(days)
            mask = df_recipes['Ingredients Cleaned'].str.contains(ingredient, case=False, na=False)
            spi_scores[mask] += urgency_score
            
        # Menghitung Final Hybrid Score
        final_scores = (cos_sim * 0.6) + (spi_scores * 0.4)
        
        # Mengambil 10 resep teratas
        top_indices = final_scores.argsort()[-10:][::-1]
        results = []
        for idx in top_indices:
            results.append({
                "title": df_recipes.iloc[idx]['Title'],
                "score": round(float(final_scores[idx]), 4),
                "ingredients": df_recipes.iloc[idx]['Ingredients'],
                "steps": df_recipes.iloc[idx]['Steps']
            })
            
        return {"recommendations": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))