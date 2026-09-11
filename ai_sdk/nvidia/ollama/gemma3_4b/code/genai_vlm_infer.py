import base64
import json
import requests
from pathlib import Path

# Change to Ollama host and model
OLLAMA_HOST = "http://localhost:11434"
MODEL_NAME = "gemma3:4b"

def encode_image_to_base64(image_path: str) -> str:
    """Read an image file and convert it to a base64 string."""
    img_path = Path(image_path)
    if not img_path.is_file():
        raise FileNotFoundError(f"Image not found: {img_path}")

    with img_path.open("rb") as f:
        img_bytes = f.read()
    return base64.b64encode(img_bytes).decode("utf-8")

def vlm_recognize(
    image_path: str,
    prompt: str = "Describe the content of this image.",
    model: str = MODEL_NAME,
    temperature: float = 0.2,
    stream: bool = False,
) -> str:
    """
    Send an image and prompt to an Ollama VLM model and return the recognition result.

    :param image_path: Path to the image file.
    :param prompt: Prompt for the VLM.
    :param model: Ollama model name.
    :param temperature: Generation temperature.
    :param stream: Whether to use streaming mode.
    :return: The model's text response.
    """
    # Convert the image to base64
    img_b64 = encode_image_to_base64(image_path)

    # Prepare the request payload
    url = f"{OLLAMA_HOST}/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": stream,
        "images": [img_b64],  # Ollama expects a list of base64 images
        "options": {"temperature": temperature},
    }

    # Send request
    resp = requests.post(url, json=payload, timeout=600)
    resp.raise_for_status()

    # Parse response
    if stream:
        result = ""
        for line in resp.iter_lines():
            if not line:
                continue
            data = json.loads(line.decode("utf-8"))
            result += data.get("response", "")
            if data.get("done"):
                break
        return result.strip()
    else:
        data = resp.json()
        return data.get("response", "").strip()

if __name__ == "__main__":
    # Replace with your image
    image_file = "test.jpg" 
    # Replace with your question
    question = "Describe this image in detail and list the main objects you see."

    try:
        output = vlm_recognize(image_file, question)
        print("=== VLM Recognition Result ===")
        print(output)
    except Exception as e:
        print("Error:", e)