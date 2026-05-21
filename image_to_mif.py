from PIL import Image

img = Image.open("dolphin.png").convert("RGB")
img = img.resize((16, 16))

with open("dolphin_sprite.mif", "w") as f:
    f.write("WIDTH=3;\n")
    f.write("DEPTH=256;\n\n")
    f.write("ADDRESS_RADIX=UNS;\n")
    f.write("DATA_RADIX=BIN;\n\n")
    f.write("CONTENT BEGIN\n")

    address = 0

    for y in range(16):
        for x in range(16):

            r, g, b = img.getpixel((x, y))

            red = 1 if r > 128 else 0
            green = 1 if g > 128 else 0
            blue = 1 if b > 128 else 0

            f.write(f"{address} : {red}{green}{blue};\n")

            address += 1

    f.write("END;\n")

print("Created dolphin_sprite.mif")