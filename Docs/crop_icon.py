from PIL import Image

def crop_icon():
    image_path = 'icon.png'
    output_path = 'icon.png' # Overwriting as per general objective to fix the icon
    
    try:
        image = Image.open(image_path)
        bbox = image.getbbox()
        
        if bbox:
            cropped_image = image.crop(bbox)
            cropped_image.save(output_path)
            print(f"Successfully cropped image. New size: {cropped_image.size}")
        else:
            print("Image is empty/transparent. No crop performed.")
            
    except Exception as e:
        print(f"Failed to crop image: {e}")

if __name__ == "__main__":
    crop_icon()
