from PIL import Image

def analyze_icon_png():
    image_path = 'icon.png'
    try:
        image = Image.open(image_path)
        print(f"Original Image Size: {image.size}")
        print(f"Image Mode: {image.mode}")
        
        bbox = image.getbbox()
        if bbox:
            print(f"Content Bounding Box: {bbox}")
            width, height = image.size
            crop_width = bbox[2] - bbox[0]
            crop_height = bbox[3] - bbox[1]
            print(f"Cropped Size: {crop_width}x{crop_height}")
            
            # Simple visualization of borders
            left_border = bbox[0]
            top_border = bbox[1]
            right_border = width - bbox[2]
            bottom_border = height - bbox[3]
            print(f"Margins - Left: {left_border}, Top: {top_border}, Right: {right_border}, Bottom: {bottom_border}")
        else:
            print("Image is completely transparent.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    analyze_icon_png()
