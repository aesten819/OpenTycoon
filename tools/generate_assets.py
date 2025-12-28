import os
from PIL import Image, ImageDraw

def create_iso_tile(filename, color, width=64, height=32, depth=16):
    # Total image size needs to accommodate the depth
    img_height = height + depth
    img = Image.new('RGBA', (width, img_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Coordinates for the top diamond
    # Top, Right, Bottom, Left
    top = (width // 2, 0)
    right = (width - 1, height // 2)
    bottom = (width // 2, height - 1)
    left = (0, height // 2)

    # Draw Top Face
    draw.polygon([top, right, bottom, left], fill=color, outline=(0,0,0,50))

    # Draw Left Face (Darker)
    left_face = [
        left,
        bottom,
        (bottom[0], bottom[1] + depth),
        (left[0], left[1] + depth)
    ]
    # Darken color
    r, g, b = color
    dark_color = (int(r*0.7), int(g*0.7), int(b*0.7))
    draw.polygon(left_face, fill=dark_color, outline=(0,0,0,50))

    # Draw Right Face (Darkest)
    right_face = [
        right,
        bottom,
        (bottom[0], bottom[1] + depth),
        (right[0], right[1] + depth)
    ]
    darker_color = (int(r*0.5), int(g*0.5), int(b*0.5))
    draw.polygon(right_face, fill=darker_color, outline=(0,0,0,50))
    
    # Save
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    img.save(filename)
    print(f"Created {filename}")

if __name__ == "__main__":
    base_dir = "i:/dev/OpenTycoon/assets"
    create_iso_tile(f"{base_dir}/tile_grass.png", (100, 200, 100)) # Green
    create_iso_tile(f"{base_dir}/tile_dirt.png", (139, 69, 19))   # Brown
    create_iso_tile(f"{base_dir}/tile_water.png", (64, 164, 223)) # Blue
    create_iso_tile(f"{base_dir}/tile_select.png", (255, 255, 0)) # Yellow Highlight
