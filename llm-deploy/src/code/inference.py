import transformers

model_name = "THUDM/chatglm2-6b"

tokenizer = transformers.AutoTokenizer.from_pretrained(
    model_name, trust_remote_code=True
)


def model_fn(model_dir):
    chatglm_pipe = transformers.AutoModel.from_pretrained(
        model_name, trust_remote_code=True
    ).half()
    chatglm_pipe.to("cuda")
    return chatglm_pipe


def predict_fn(data, pipe):
    text = data.pop("text", data)
    response, history = pipe.chat(tokenizer, text, history=[])
    return response, history
