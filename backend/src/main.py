import uvicorn
from fastapi import FastAPI
from fastapi.routing import APIRoute

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

def start_server():
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

if __name__ == "__main__":
    start_server()