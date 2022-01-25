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

from myhdl import *
import os
import sys

sys.path.append("verilog-ethernet/tb/")

import axis_ep
import eth_ep

module = 'matrixledcontroller'
testbench = 'test_%s' % module

srcs = []

srcs.append("%s.v" % module)
srcs.append("./verilog-ethernet/rtl/eth_axis_rx.v")
srcs.append("./verilog-ethernet/lib/axis/rtl/axis_async_fifo.v")
srcs.append("./verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    TARGET = "SIM"
    AXIS_DATA_WIDTH = 8;
    AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8);
    AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8);
    ENABLE_PADDING = 1;
    MIN_FRAME_LENGTH = 64;
    TX_FIFO_DEPTH = 4096;
    TX_FRAME_FIFO = 1;
    TX_DROP_BAD_FRAME = TX_FRAME_FIFO;
    TX_DROP_WHEN_FULL = 0;
    RX_FIFO_DEPTH = 4096;
    RX_FRAME_FIFO = 1;
    RX_DROP_BAD_FRAME = RX_FRAME_FIFO;
    RX_DROP_WHEN_FULL = RX_FRAME_FIFO;

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))

    s_axis_tdata = Signal(intbv(0)[AXIS_DATA_WIDTH:])
    s_axis_tkeep = Signal(intbv(1)[AXIS_KEEP_WIDTH:])
    s_axis_tvalid = Signal(bool(0))
    s_axis_tlast = Signal(bool(0))
    s_axis_tuser = Signal(bool(0))

    # Outputs
    s_axis_tready = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        clk=clk,
        rst=rst,
        tdata=s_axis_tdata,
        tkeep=s_axis_tkeep,
        tvalid=s_axis_tvalid,
        tready=s_axis_tready,
        tlast=s_axis_tlast,
        tuser=s_axis_tuser,
        pause=source_pause,
        name='source'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        rx_axis_tdata=s_axis_tdata,
        rx_axis_tkeep=s_axis_tkeep,
        rx_axis_tvalid=s_axis_tvalid,
        rx_axis_tready=s_axis_tready,
        rx_axis_tlast=s_axis_tlast,
        rx_axis_tuser=s_axis_tuser
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge


        # testbench stimulus
        yield delay(1000)

        yield clk.posedge
        print("test 1: test rx packet")

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(24))

        axis_frame = test_frame.build_axis()

        source.send(axis_frame)

        #yield source.wait()
        while s_axis_tvalid:
            yield clk.posedge
        
        for i in range(100):
            yield clk.posedge

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
