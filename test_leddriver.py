#!/usr/bin/env python
"""

Copyright (c) 2019 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

from curses.ascii import SI
from myhdl import *
import os
import numpy as np
import array

module = 'leddriver'
testbench = 'test_%s' % module

srcs = []

srcs.append("%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    r0 = Signal(intbv(0)[3:])
    r1 = Signal(intbv(0)[3:])
    g0 = Signal(intbv(0)[3:])
    g1 = Signal(intbv(0)[3:])
    b0 = Signal(intbv(0)[2:])
    b1 = Signal(intbv(0)[2:])

    # Outputs
    row = Signal(intbv(0)[4:])
    col = Signal(intbv(0)[6:])
    frame_start = Signal(bool(0))
    panel_r0 = Signal(bool(0))    
    panel_r1 = Signal(bool(0))
    panel_g0 = Signal(bool(0))    
    panel_g1 = Signal(bool(0))
    panel_b0 = Signal(bool(0))    
    panel_b1 = Signal(bool(0))
    panel_pa1 = Signal(bool(0))    
    panel_pa2 = Signal(bool(0))
    panel_pa3 = Signal(bool(0))    
    panel_pa4 = Signal(bool(0))
    panel_sclk = Signal(bool(0))
    panel_latch = Signal(bool(0))    
    panel_blank = Signal(bool(0))

    # Individual line shift registers
    r0shift = np.uint64(0)
    r1shift = np.uint64(0)
    g0shift = np.uint64(0)
    g1shift = np.uint64(0)
    b0shift = np.uint64(0)
    b1shift = np.uint64(0)

    # Panel Pixels
    panel = array.array('B', [0,0,0] * 64 * 32)
    bitpos = 0

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        rst=rst,
        clk=clk,
        r0=r0,
        r1=r1,
        g0=g0,
        g1=g1,
        b0=b0,
        b1=b1,
        row=row,
        col=col,
        frame_start=frame_start,
        panel_r0=panel_r0,
        panel_r1=panel_r1,
        panel_g0=panel_g0,
        panel_g1=panel_g1,
        panel_b0=panel_b0,
        panel_b1=panel_b1,
        panel_pa1=panel_pa1,
        panel_pa2=panel_pa2,
        panel_pa3=panel_pa3,
        panel_pa4=panel_pa4,
        panel_sclk=panel_sclk,
        panel_latch=panel_latch,
        panel_blank=panel_blank 
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    @always_comb
    def colorchoose():
        if (col < 16):
            r0.next = 7
            r1.next = 7
            g0.next = 0
            g1.next = 0
            b0.next = 0
            b1.next = 0
        elif (col < 32):
            r0.next = 0
            r1.next = 0
            g0.next = 7
            g1.next = 7
            b0.next = 0
            b1.next = 0
        elif (col < 48):
            r0.next = 0
            r1.next = 0
            g0.next = 0
            g1.next = 0
            b0.next = 3
            b1.next = 3 
        else:
            r0.next = 0
            r1.next = 0
            g0.next = 0
            g1.next = 0
            b0.next = 0
            b1.next = 0                                

    @always(panel_sclk.posedge)
    def shift():
        nonlocal r0shift, r1shift, g0shift, g1shift, b0shift, b1shift

        r0shift = (r0shift >> np.uint64(1)) | (np.uint64(0x8000000000000000) if panel_r0 else np.uint64(0))
        r1shift = (r1shift >> np.uint64(1)) | (np.uint64(0x8000000000000000) if panel_r1 else np.uint64(0))
        g0shift = (g0shift >> np.uint64(1)) | (np.uint64(0x8000000000000000) if panel_g0 else np.uint64(0))
        g1shift = (g1shift >> np.uint64(1)) | (np.uint64(0x8000000000000000) if panel_g1 else np.uint64(0))
        b0shift = (b0shift >> np.uint64(1)) | (np.uint64(0x8000000000000000) if panel_b0 else np.uint64(0))
        b1shift = (b1shift >> np.uint64(1)) | (np.uint64(0x8000000000000000) if panel_b1 else np.uint64(0))

    @always(panel_latch.posedge)
    def latch():
        nonlocal bitpos

        pa = panel_pa1 | panel_pa2 << 1 | panel_pa3 << 2 | panel_pa4 << 3

        for i in range(64):
            mask = np.uint64(0x8000000000000000) >> np.uint64(i)
            offset = pa * 64 * 3 + (i * 3)
            offset2 = (pa + 16) * 64 * 3 + (i * 3)
        
            if r0shift & mask:
                panel[offset] = 1 if bitpos == 0 else panel[offset] | 1 << bitpos 
            if r1shift & mask:
                panel[offset2] = 1 if bitpos == 0 else panel[offset2] | 1 << bitpos 
            if g0shift & mask:
                panel[offset + 1] = 1 if bitpos == 0 else panel[offset + 1] | 1 << bitpos 
            if g1shift & mask:
                panel[offset2 + 1] = 1 if bitpos == 0 else panel[offset2 + 1] | 1 << bitpos 
            if b0shift & mask:
                panel[offset + 2] = 1 if bitpos == 0 else panel[offset + 2] | 1 << bitpos 
            if b1shift & mask:
                panel[offset2 + 2] = 1 if bitpos == 0 else panel[offset2 +2] | 1 << bitpos 

        bitpos = bitpos + 1
        if bitpos > 2:
            bitpos = 0

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        yield clk.posedge
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        # testbench stimulus
        yield delay(1000)

        yield clk.posedge
        print("Output a frame")

        yield frame_start.posedge

        width = 64
        height = 32
        maxval = 7

        ppm_header = f'P6 {width} {height} {maxval}\n'
        with open('panel.ppm', 'wb') as f:
            f.write(bytearray(ppm_header, 'ascii'))
            panel.tofile(f)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
