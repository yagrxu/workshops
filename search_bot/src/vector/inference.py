from sentence_transformers import SentenceTransformer

model_id = "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"

def model_fn(model_dir):
    model = SentenceTransformer(model_id)
    return  model


def predict_fn(data, pipe):
    text = data.pop("text", data)
    return pipe.encode([text])[0]
