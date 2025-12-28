import os
import sys
from PIL import Image

def process_gate_image(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return

    img = Image.open(input_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    # Simple White Background Removal
    for item in datas:
        # Check if nearly white (tolerance)
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)

    img.putdata(new_data)
    
    # Auto Crop (Get Content)
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Processed {input_path} -> {output_path} (Size: {img.size})")

if __name__ == "__main__":
    # Usage: python process_gate.py <filename>
    if len(sys.argv) > 1:
        target_file = sys.argv[1]
        folder = os.path.dirname(target_file)
        filename = os.path.basename(target_file)
        name_no_ext = os.path.splitext(filename)[0]
        
        # Save as _processed.png
        output = os.path.join(folder, f"{name_no_ext}_processed.png")
        process_gate_image(target_file, output)
    else:
        print("Please provide a filename to process.")
        print("Usage: python tools/process_gate.py assets/building/gate_back.png")
