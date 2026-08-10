from scapy.all import rdpcap
from scapy.layers.inet import IP

packets = rdpcap('netcap-ShutCorp.pcap')

ips = set()
for packet in packets:
    if packet.haslayer(IP):
        ips.add(packet[IP].src)
        ips.add(packet[IP].dst)

for ip in sorted(ips):
    print(ip)