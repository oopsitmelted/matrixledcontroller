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

import mii_ep
import eth_ep

module = 'matrixledcontroller'
testbench = 'test_%s' % module

srcs = []

srcs.append("%s.v" % module)
srcs.append("./verilog-ethernet/rtl/eth_axis_rx.v")
srcs.append("./verilog-ethernet/lib/axis/rtl/axis_async_fifo.v")
srcs.append("./verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v")
srcs.append("./verilog-ethernet/rtl/eth_mac_mii_fifo.v")
srcs.append("./verilog-ethernet/rtl/eth_mac_mii.v")
srcs.append("./verilog-ethernet/rtl/eth_mac_1g.v")
srcs.append("./verilog-ethernet/rtl/mii_phy_if.v")
srcs.append("./verilog-ethernet/rtl/axis_gmii_rx.v")
srcs.append("./verilog-ethernet/rtl/axis_gmii_tx.v")
srcs.append("./verilog-ethernet/rtl/ssio_sdr_in.v")
srcs.append("./verilog-ethernet/rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    TARGET = "SIM"
    AXIS_DATA_WIDTH = 8
    AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8)
    AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8)
    ENABLE_PADDING = 1
    MIN_FRAME_LENGTH = 64
    TX_FIFO_DEPTH = 4096
    TX_FRAME_FIFO = 1
    TX_DROP_BAD_FRAME = TX_FRAME_FIFO
    TX_DROP_WHEN_FULL = 0
    RX_FIFO_DEPTH = 4096
    RX_FRAME_FIFO = 1
    RX_DROP_BAD_FRAME = RX_FRAME_FIFO
    RX_DROP_WHEN_FULL = RX_FRAME_FIFO

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))

    mii_rx_clk = Signal(bool(0))
    mii_rxd = Signal(intbv(0)[4:])
    mii_rx_dv = Signal(bool(0))
    mii_rx_er = Signal(bool(0))
    mii_tx_clk = Signal(bool(0))
    mii_txd = Signal(intbv(0)[4:])
    mii_tx_en = Signal(bool(0))

    # Outputs

    # sources and sinks
    mii_source = mii_ep.MIISource()

    mii_source_logic = mii_source.create_logic(
        mii_rx_clk,
        rst,
        txd=mii_rxd,
        tx_en=mii_rx_dv,
        tx_er=mii_rx_er,
        name='mii_source'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        mii_rx_clk=mii_rx_clk,
        mii_rxd=mii_rxd,
        mii_rx_dv=mii_rx_dv,
        mii_rx_er=mii_rx_er,
        mii_tx_clk=mii_tx_clk,
        mii_txd=mii_txd,
        mii_tx_en=mii_tx_en
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        mii_rx_clk.next = not mii_rx_clk
        mii_tx_clk.next = not mii_tx_clk

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
        print("test 1: test rx packet")

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))
        test_frame.update_fcs()

        axis_frame = test_frame.build_axis_fcs()

        mii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))
        mii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))
        for i in range(1000):
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
