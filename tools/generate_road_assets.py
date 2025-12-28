import os
from PIL import Image, ImageDraw

def create_iso_face(draw, vertices, color):
    draw.polygon(vertices, fill=color, outline=(0,0,0,50))

def create_road_tile(filename, color, width=64, height=32, is_queue=False):
    # Road is slightly thinner than a full block to sit on top or replace ground
    # Let's make it a full block for simplicity of replacement
    depth = 16 
    img_height = height + depth
    img = Image.new('RGBA', (width, img_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Coordinates
    top = (width // 2, 0)
    right = (width - 1, height // 2)
    bottom = (width // 2, height - 1)
    left = (0, height // 2)

    # Draw Depth Faces first (so they are behind)
    # Left Face
    left_face = [left, bottom, (bottom[0], bottom[1] + depth), (left[0], left[1] + depth)]
    r, g, b = color
    dark_color = (int(r*0.7), int(g*0.7), int(b*0.7))
    create_iso_face(draw, left_face, dark_color)

    # Right Face
    right_face = [right, bottom, (bottom[0], bottom[1] + depth), (right[0], right[1] + depth)]
    darker_color = (int(r*0.5), int(g*0.5), int(b*0.5))
    create_iso_face(draw, right_face, darker_color)

    # Top Face (The Road Surface)
    create_iso_face(draw, [top, right, bottom, left], color)

    # Details
    if is_queue:
        # Draw queue railings (simplified as posts)
        post_color = (200, 200, 200)
        # Left post
        draw.rectangle([left[0]+10, left[1]-5, left[0]+14, left[1]], fill=post_color)
        # Right post
        draw.rectangle([right[0]-14, right[1]-5, right[0]-10, right[1]], fill=post_color)
        # Lines
        draw.line([left, right], fill=(255,255,255,100), width=2)

    os.makedirs(os.path.dirname(filename), exist_ok=True)
    img.save(filename)
    print(f"Created {filename}")

if __name__ == "__main__":
    base_dir = "i:/dev/OpenTycoon/assets/road"
    
    # Standard Asphalt Path
    create_road_tile(f"{base_dir}/road_asphalt.png", (100, 100, 100)) 
    
    # Queue Line (Blue Tarmac)
    create_road_tile(f"{base_dir}/road_queue.png", (60, 80, 120), is_queue=True)
