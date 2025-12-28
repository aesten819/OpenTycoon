import os
import sys
from PIL import Image

def process_peep():
    input_path = "assets/peep/peep.png"
    output_path = "assets/peep/peep_texture.png"

    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return

    print(f"Processing {input_path}...")
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
    
    # 2. Crop BBox (Content only)
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        print(f"Cropped to content: {bbox}")
    else:
        print("Image seems empty (all white?).")
        return
        
    # 3. Handling User's Sprite Sheet vs Single Image
    # If the image is wide (aspect ratio > 2:1), assume it's a strip/sheet.
    # We just want ONE frame for our procedural animation.
    # Let's crop the first square-ish chunk from the left.
    w, h = img.size
    if w > h * 1.5:
        # Crop the first 'h' pixels width (making it h x h square approximation)
        # Or if it's very distinct, try to scan vertical clear space. 
        # For simplicity, let's take the first 1/4th if it's a 4-frame strip.
        # Assuming 4 frames horizontal.
        frame_width = w // 4
        img = img.crop((0, 0, frame_width, h))
        # Re-crop bbox in case of spacing
        if img.getbbox():
            img = img.crop(img.getbbox())
        print(f"Extracted first frame. New size: {img.size}")

    # 4. Resize to Game Scale
    # RCT2 peeps are tiny, roughly 16x22 pixels visually + margin.
    # Let's target height = 24 pixels (slightly larger than 1 tile unit which is huge? Grid is 64x32).
    # Walls are like 64px high? No, walls are taller.
    # Let's target Height = 32px.
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
    process_peep()
