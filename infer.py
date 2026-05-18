import os
import torch

from transformers import AutoModelForCausalLM, AutoTokenizer


def main():
    # Use the default model path in container, fallback to local path.
    path = os.environ.get("MODEL_PATH", "/workspace/models/Qwen3-0.6B")
    if not os.path.exists(path):
        path = os.path.expanduser("~/huggingface/Qwen3-0.6B/")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    tokenizer = AutoTokenizer.from_pretrained(path)
    model = AutoModelForCausalLM.from_pretrained(
        path,
        torch_dtype="auto",
    ).to(device).eval()

    prompt = "introduce yourself"
    # Chat template is optional. For chat/instruct models, enabling it often gives
    # better alignment with the expected dialogue format.
    # For this minimal example, we use the raw prompt directly.
    # text_for_model = prompt
    text_for_model = tokenizer.apply_chat_template(
        [{"role": "user", "content": prompt}],
        tokenize=False,
        add_generation_prompt=True,
    )
    model_inputs = tokenizer(text_for_model, return_tensors="pt").to(device)
    generated_ids = model.generate(
        **model_inputs,
        do_sample=True,
        temperature=0.6,
        max_new_tokens=256,
    )
    new_token_ids = generated_ids[0][model_inputs["input_ids"].shape[1]:]
    output_text = tokenizer.decode(new_token_ids, skip_special_tokens=False)
    print(f"Prompt: {prompt}")
    print(f"Completion: {output_text}")


if __name__ == "__main__":
    main()
