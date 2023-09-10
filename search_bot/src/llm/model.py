from djl_python import Input, Output
from transformers import AutoTokenizer, AutoModel

model = None
tokenizer = None


def get_model(properties):
    model_name = properties["model_id"]
    model = AutoModel.from_pretrained(model_name, trust_remote_code=True).half().cuda()
    tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    return model, tokenizer


def stream_items(prompt, history, max_length, top_p, temperature):
    global model, tokenizer
    size = 0
    response = ""
    for response, history in model.stream_chat(
        tokenizer,
        prompt,
        history=history,
        max_length=max_length,
        top_p=top_p,
        temperature=temperature,
    ):
        this_response = response[size:]
        history = [list(h) for h in history]
        size = len(response)
        stream_buffer = {"outputs": this_response, "history": history}
        yield stream_buffer


def handle(inputs: Input) -> None:
    global model, tokenizer
    if not model:
        model, tokenizer = get_model(inputs.get_properties())

    if inputs.is_empty():
        return None
    input_map = inputs.get_as_json()
    data = input_map.pop("inputs", input_map)
    params = input_map.pop("parameters", {})
    history = input_map["history"]
    model = model.eval()
    outputs = Output()
    outputs.add_property("content-type", "application/jsonlines")
    outputs.add_stream_content(stream_items(data, history=history, **params))
    return outputs
