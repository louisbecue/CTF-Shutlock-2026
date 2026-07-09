import hashlib
import sys
import mla

path = "codepin_corrupted.mla"
signature = mla.SignatureConfig.without_signature_verification()
config = mla.ReaderConfig.without_encryption(signature)
mla_reader = mla.MLAReader(path, config)
datas = mla_reader.list_entries(include_size=True, include_hash=True)
print(datas.items())
h = ""
for _, data in datas.items():
    h = bytes(data.hash).hex()
    print(f"Hash : {h}")
    break

for i in range(10000):
    test = f"{i:04d}".encode()
    if hashlib.sha256(test).hexdigest() == h:
        print(test.decode())
        break