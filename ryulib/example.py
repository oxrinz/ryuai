import ctypes

lib = ctypes.CDLL('./zig-out/libstarter.so')  

result = lib.add(5, 3)
print(f"5 + 3 = {result}")
lib.hello()