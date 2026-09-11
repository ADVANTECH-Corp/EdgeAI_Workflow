# GenAI - VLM Image Recognition (Python)

This sample code provides a Python script for sending images to an **Vision-Language Model (VLM)** such as `gemma3:4b`, or other multimodal models that support image input.

Using the Ollama inference service inside the genai-chatbot module of the Edge AI SDK, the script encodes an image in Base64, sends it to Ollama's `/api/generate` endpoint, and returns the model's recognition / description result.

## Setups
1. Open **GenAI-Chatbot** on Edge AI SDK.
2. Ensure you have an Ollama server running locally or remotely.
    ```bash
    docker ps -a | grep ollama
    ```
3. Make sure you have the desired VLM model (e.g., `gemma3:4b`) installed on Ollama server.

## Requirements

Install dependencies:

```bash
pip install requests pillow
```

## Usage
1. Update the `model_name`, `image_file`, and `question` variables in the python script as needed. - Path: `code/genai_vlm_infer.py`
2. Run the python script:
    ```bash
    cd code
    python genai_vlm_infer.py
    ```
3. The script will print the model's response to the console.
    ```
    === VLM Recognition Result ===
    (The model-generated description...)
    ```