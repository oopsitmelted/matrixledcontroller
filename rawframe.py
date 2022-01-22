#!/usr/bin/python3

from socket import *
from getmac import get_mac_address

def mac_to_bytes(mac: str):
  return bytes(bytearray.fromhex("".join(mac.split(":"))))

def sendeth(dst_mac, payload, interface = "eno1"):
  """Send raw Ethernet packet on interface."""
  s = socket(AF_PACKET, SOCK_RAW)

  src_mac = mac_to_bytes(get_mac_address(interface="eno1"))

  pl = len(payload).to_bytes(2, 'big')
  g = bytes(dst_mac) + src_mac + pl + bytes(payload)

  s.bind((interface, 0))
  return s.send(g)


if __name__ == "__main__":
      dst = [0x02, 0x00, 0x01, 0x02, 0x03, 0x04]
      payload = [1, 2, 3, 4]

      r = sendeth(dst, payload)
      print("Sent Ethernet payload of length %d bytes" % r)