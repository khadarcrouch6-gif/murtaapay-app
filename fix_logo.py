from PIL import Image
import sys

try:
    img = Image.open('assets/images/app_logo.png')
    img = img.convert("RGBA")
    
    bg = Image.new("RGBA", img.size, "WHITE")
    bg.paste(img, (0, 0), img)
    bg = bg.convert("RGB")
    
    bg.save('assets/images/app_logo_ios.png')
    print("Success")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
