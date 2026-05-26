from PIL import Image
import os

INPUT_IMAGE  = r"backgroundnowave.png"
OUTPUT_MIF   = "sunset.mif"
WIDTH        = 260
HEIGHT       = 190

img = Image.open(INPUT_IMAGE).convert("RGB")
img = img.resize((WIDTH, HEIGHT), Image.NEAREST)

with open(OUTPUT_MIF, "w") as f:
    f.write("WIDTH=12;\n")
    f.write(f"DEPTH={WIDTH * HEIGHT};\n\n")
    f.write("ADDRESS_RADIX=HEX;\n")
    f.write("DATA_RADIX=HEX;\n\n")
    f.write("CONTENT BEGIN\n")

    addr = 0
    for y in range(HEIGHT):
        for x in range(WIDTH):
            r, g, b = img.getpixel((x, y))
            r4 = r >> 4
            g4 = g >> 4
            b4 = b >> 4
            rgb444 = (r4 << 8) | (g4 << 4) | b4
            f.write(f"{addr:04X} : {rgb444:03X};\n")
            addr += 1

    f.write("END;\n")

print("done")