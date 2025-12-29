import os
import sys
from PIL import Image

def process_peep_walk(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return

    img = Image.open(input_path).convert("RGBA")
    
    # 1. Remove White Background
    datas = img.getdata()
    new_data = []
    
    for item in datas:
        # Check for white/near-white
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
             new_data.append((255, 255, 255, 0))
        else:
             new_data.append(item)
    
    img.putdata(new_data)
    
    # 2. Crop to Content
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        
    # 3. Resize
    # The image is likely big (AI generated). We need to shrink it.
    # We want each frame to be approx 16-24px wide?
    # Current aspect: 4 frames horizontal.
    # Total Width / 4 = Frame Width.
    # Target Height = 32px.
    
    target_height = 32
    if img.height > target_height:
        ratio = target_height / float(img.height)
        new_width = int(img.width * ratio)
        img = img.resize((new_width, target_height), Image.Resampling.LANCZOS)
        print(f"Resized to {new_width}x{target_height}")
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Saved to {output_path}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target = sys.argv[1]
        # Auto-name output based on input if not specified
        folder = os.path.dirname(target)
        filename = os.path.basename(target)
        name_no_ext = os.path.splitext(filename)[0]
        output = os.path.join("assets/peep", "peep_walk_back.png") # Force output name for game consistency
        
        print(f"Targeting: {target} -> {output}")
        process_peep_walk(target, output)
    else:
        print("Usage: python tools/process_peep_walk.py <path_to_input_image>")
        print("Example: python tools/process_peep_walk.py assets/peep/my_raw_image.png")
