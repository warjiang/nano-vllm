import os
from nanovllm import LLM, SamplingParams
from transformers import AutoTokenizer


def main():
    # Use the default model path in container, fallback to local path
    path = os.environ.get("MODEL_PATH", "/workspace/models/Qwen3-0.6B")
    if not os.path.exists(path):
        path = os.path.expanduser("~/huggingface/Qwen3-0.6B/")
    
    tokenizer = AutoTokenizer.from_pretrained(path)
    llm = LLM(path, enforce_eager=True, tensor_parallel_size=1)

    sampling_params = SamplingParams(temperature=0.6, max_tokens=256)
    prompts = [
        "introduce yourself",
        "list all prime numbers within 100",
    ]
    """
    [
        '<|im_start|>user\nintroduce yourself<|im_end|>\n<|im_start|>assistant\n', 
        '<|im_start|>user\nlist all prime numbers within 100<|im_end|>\n<|im_start|>assistant\n']
    """
    prompts = [
        tokenizer.apply_chat_template(
            [{"role": "user", "content": prompt}],
            tokenize=False,
            add_generation_prompt=True,
        )
        for prompt in prompts
    ]
    outputs = llm.generate(prompts, sampling_params)

    """
    Prompt: '<|im_start|>user\nintroduce yourself<|im_end|>\n<|im_start|>assistant\n'
    Completion: "<think>\nOkay, the user wants me to introduce myself. Let me start by recalling my role. I'm a language model designed to assist with different tasks. I can help with writing, grammar, math, or even general knowledge. I need to make sure my introduction is friendly and covers my main functions.\n\nI should mention my capabilities in a clear way. Maybe start with a greeting, then list what I can do. Keep it concise but informative. Also, note that I'm trained on a large dataset, so I can handle various queries. Make sure to stay positive and offer help if they need anything else. That should cover the basics.\n</think>\n\nHello! I'm a language model designed to assist with a wide range of tasks. I can help with writing, grammar, math, general knowledge, and more. How can I assist you today? Let me know!<|im_end|>"


    Prompt: '<|im_start|>user\nlist all prime numbers within 100<|im_end|>\n<|im_start|>assistant\n'
    Completion: "<think>\nOkay, so I need to list all the prime numbers between 100. Let me think about how to approach this. First, I remember that a prime number is a number greater than 1 that has no positive divisors other than 1 and itself. So, starting from 100, I need to check each number to see if it's a prime.\n\nLet me start by recalling some prime numbers. I know that primes less than 100 are 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97. So, those are the primes up to 100. But wait, I need to ensure that I don't miss any. Let me check if there are any primes between 100 and 100, which is just 100 itself. Since 100 isn"
    """
    for prompt, output in zip(prompts, outputs):
        print("\n")
        print(f"Prompt: {prompt!r}")
        print(f"Completion: {output['text']!r}")


if __name__ == "__main__":
    main()
