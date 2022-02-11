from io import TextIOWrapper
import sys
import os

def twos_comp(val):
    return (val ^ 0xFF) + 1     

def main():
    #if len(sys.argv) != 2:
    #    print ("Invalid arguments")
    #    exit()

    #file = open(sys.argv[1], 'r')
    file = open("image.ppm", 'r')
    ppm = file.read().splitlines(True)

    # Delete comment lines
    line_no = 0
    while line_no < len(ppm):
        if ppm[line_no].startswith("#"):
            del ppm[line_no]

        line_no = line_no + 1

    # Join and split into tokens
    ppm = "".join(ppm).split()

    if ppm[0] != "P3":
        print ("Not a PPM file")
        exit()

    cols = int(ppm[1])
    rows = int(ppm[2])
    maxval = int(ppm[3])

    matrix = []
    for r in range(0, int(rows / 2)):
        row1 = []
        row2 = []

        for c in range(0, cols * 3, 3):
            row1.append(int(ppm[4 + r*cols*3 + c])) #red
            row1.append(int(ppm[4 + r*cols*3 + c + 1])) #green
            row1.append(int(ppm[4 + r*cols*3 + c + 2])) #blue
            row2.append(int(ppm[4 + (r + int(rows/2))*cols*3 + c])) #red
            row2.append(int(ppm[4 + (r + int(rows/2))*cols*3 + c + 1])) #green
            row2.append(int(ppm[4 + (r + int(rows/2))*cols*3 + c + 2])) #blue

        # Reverse and interleave the rows
        for c in range(cols * 3 - 1, -1, -3):
            byte = row1[c - 2] & 0xE0           #red
            byte |= (row1[c - 1] & 0xE0 ) >> 3  #green
            byte |= row1[c - 0] >> 6            #blue

            matrix.append(byte)

            byte = row2[c - 2] & 0xE0           #red
            byte |= (row2[c - 1] & 0xE0) >> 3   #green
            byte |= row2[c - 0] >> 6            #blue

            matrix.append(byte)

    # Output hex file
    hexfile = open("image.hex", 'w')
    bytes_remaining = len(matrix)

    while bytes_remaining:
        bytes_to_write = min(16, bytes_remaining)
        index = len(matrix) - bytes_remaining

        # Create the line
        line = ":" + format(bytes_to_write, '02X') + format(index, '04X') + "00"
        xsum = bytes_to_write + (index >> 8) + (index & 0xFF)

        for i in range(0, bytes_to_write):
            val = matrix[index]
            line = line + format(val, '02X')
            xsum = xsum + val
            index = index + 1

        line = line + format(twos_comp(xsum % 256), '02X') + '\n'
        hexfile.write(line)
        bytes_remaining = bytes_remaining - bytes_to_write

    hexfile.write(":00000001FF\n")
    hexfile.close()

main()