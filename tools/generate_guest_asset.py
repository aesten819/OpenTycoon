from PIL import Image, ImageDraw
import os

def create_guest_asset():
    # Road tile is typically 64px wide.
    # 1/3 size is approx 21.3px. Let's make it 22px for evenness.
    size = 22
    
    # Create transparent image
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw White Circle
    # Bounding box [x0, y0, x1, y1]
    # Leave 1px padding
    draw.ellipse([1, 1, size-2, size-2], fill=(255, 255, 255, 255), outline=(200, 200, 200, 255))
    
    target_dir = r"i:/dev/OpenTycoon/assets/peep"
    os.makedirs(target_dir, exist_ok=True)
    
    output_path = os.path.join(target_dir, "guest_circle.png")
    img.save(output_path)
    print(f"Created guest asset: {output_path}")

if __name__ == "__main__":
    create_guest_asset()
