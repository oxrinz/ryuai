import serial

# Configure serial port
ser = serial.Serial(
   port='/dev/ttyUSB1',
   baudrate=115200,  # Match your FPGA settings
   bytesize=serial.EIGHTBITS,
   parity=serial.PARITY_NONE,
   stopbits=serial.STOPBITS_ONE
)

# Send data
ser.write(b'your data here')

# Read data
data = ser.read(num_bytes)  # Specify number of bytes to read
# Or read line
data = ser.readline()

ser.close()