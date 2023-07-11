import transformers
from sentence_transformers import SentenceTransformer
import torch.nn.functional as F

model_name = "THUDM/chatglm2-6b"
embeddings_id2 = "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"

tokenizer = transformers.AutoTokenizer.from_pretrained(
    model_name, trust_remote_code=True
)


def model_fn(model_dir):
    chatglm_pipe = transformers.AutoModel.from_pretrained(
        model_name, trust_remote_code=True
    ).half()
    chatglm_pipe.to("cuda")

    embeddings_model2 = SentenceTransformer(embeddings_id2)
    embeddings_model2.to("cuda")
    return chatglm_pipe, embeddings_model2


def predict_fn(data, pipe):
    text = data.pop("text", data)
    type = data.pop("type", 0)

    chatglm_pipe, embeddings_model2 = pipe
    if type == 2:  # ChatGLM embeddings
        return embeddings_model2.encode([text])[0]
    else:  # ChatGLM Chat
        response, _ = chatglm_pipe.chat(tokenizer, text, history=[])
        return response
