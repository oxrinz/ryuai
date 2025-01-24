import struct

def float_to_bits(f):
    # Pack float into 4 bytes and convert to an integer
    bits = struct.unpack('!I', struct.pack('!f', f))[0]
    return bits

def bits_to_float(b):
    # Pack integer into 4 bytes and convert to float
    return struct.unpack('!f', struct.pack('!I', b))[0]

def multiply_floats_bitwise(a, b):
    # Convert floats to their binary representation
    a_bits = float_to_bits(a)
    b_bits = float_to_bits(b)
    
    # Extract sign bits (MSB)
    sign_a = (a_bits >> 31) & 1
    sign_b = (b_bits >> 31) & 1
    
    # Calculate result sign using XOR
    result_sign = sign_a ^ sign_b
    
    # Extract exponents (bits 23-30)
    exp_a = ((a_bits >> 23) & 0xFF)
    exp_b = ((b_bits >> 23) & 0xFF)
    
    print(bin(exp_a))
    print(bin(exp_b))
        
    # Calculate result exponent
    result_exp = exp_a + exp_b - 127
    
    # Extract mantissas (bits 0-22)
    mantissa_a = (a_bits & 0x7FFFFF) | 0x800000  # Add implied 1
    mantissa_b = (b_bits & 0x7FFFFF) | 0x800000  # Add implied 1
    
    # Multiply mantissas
    result_mantissa = (mantissa_a * mantissa_b) >> 23
    
    # Normalize result if necessary
    if result_mantissa & 0x1000000:  # If bit 24 is set
        result_mantissa >>= 1
        result_exp += 1
    
    # Handle special cases
    if result_exp >= 0xFF:  # Overflow
        return float('inf') if result_sign == 0 else float('-inf')
    elif result_exp <= 0:  # Underflow
        return 0.0
    
    # Combine components
    result_bits = (result_sign << 31) | (result_exp << 23) | (result_mantissa & 0x7FFFFF)
    
    return bits_to_float(result_bits)

print(multiply_floats_bitwise(25, 6))