class BitStreamWriter:
    def __init__(self, file):
        self.file = file
        self.current_byte = 0
        self.bit_count = 0
    
    def write_bits(self, value, num_bits):
        for bit_pos in range(num_bits - 1, -1, -1):
            bit = (value >> bit_pos) & 1
            self.current_byte = (self.current_byte << 1) | bit
            self.bit_count += 1
            
            if self.bit_count == 8:
                self.file.write(bytes([self.current_byte]))
                self.current_byte = 0
                self.bit_count = 0
    
    def flush(self):
        if self.bit_count > 0:
            self.current_byte = self.current_byte << (8 - self.bit_count)
            self.file.write(bytes([self.current_byte]))
            self.current_byte = 0
            self.bit_count = 0

def write_instruction(file, opcode, operands_with_sizes):
    writer = BitStreamWriter(file)
    writer.write_bits(opcode, 4)
    
    for value, num_bits in operands_with_sizes:
        writer.write_bits(value, num_bits)
    
    writer.flush()

with open("program", "wb") as file:
    write_instruction(file, 0b0000, [
        (0b101, 3),
        (0x000, 3),
        (0b101111, 6),
        (0xFFFF, 16)
    ])