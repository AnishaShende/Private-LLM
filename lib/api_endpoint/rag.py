from fastapi import FastAPI
from pydantic import BaseModel
import chromadb

class QueryRequest(BaseModel):
    query_text: str

app = FastAPI()

# Initialize ChromaDB client and collection
client = chromadb.HttpClient()
collection = client.get_or_create_collection("anisha_db")

@app.post("/query/")
def query_chromadb(query: QueryRequest, n_results: int = 2):
    results = collection.query(query_texts=[query.query_text], n_results=n_results)
    return {
        "results": [
            {
                "question": results["metadatas"][0][i]["question"],
                "answer": results["documents"][0][i],
            }
            for i in range(len(results["documents"][0]))
        ]
    }