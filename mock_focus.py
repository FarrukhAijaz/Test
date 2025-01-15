import socket
import struct
import time

import numpy as np

import threading



# Define the format string for the structure (make sure it matches the data types and order)
AC_OUT_CHAR_FORMAT = 'HHIB'
AC_OUT_UINT_FORMAT = 'HHII'
FOCUS_OUT_CHAR_FORMAT = 'HHIBBB'
FOCUS_OUT_UINT_FORMAT = 'HHII'


# Define the sine wave parameters
frequency = 2  # Frequency in Hz
amplitude = 2  # Amplitude
times = np.linspace(0, 2, 1000)  # Time from 0 to 2 seconds, 1000 points
phase = 0  # Phase shift

# Generate the sine wave
sine_wave = amplitude * np.sin(2 * np.pi * frequency * times + phase)

SERVICE_ID_AC = 1
SERVICE_ID_FOCUS = 2
EVENT_ID_AC_CHAR = 0
EVENT_ID_AC_UINT = 1
EVENT_ID_FOCUS_CHAR_ARR = 0
EVENT_ID_FOCUS_UINT = 1




def pack_data_char(service_id, event_id, length,data1,data2,data3,data_format):
    packed_data = struct.pack(data_format,service_id, event_id, length,data1,data2,data3)
    return packed_data
def pack_data_uint(service_id, event_id, length,data,data_format):
    packed_data = struct.pack(data_format,service_id, event_id, length,data)
    return packed_data


UDP_IP = "127.0.0.1"  # Replace with the target IP
HOST_PORT = 43445
UDP_PORT = 43447         # Replace with the target port
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # UDP socket

def send_udp(data):
    sock.sendto(data, (UDP_IP, UDP_PORT))

def udp_receive(udp_socket):
    while True:
        # Receive data from the UDP socket
        data, client_address = udp_socket.recvfrom(4096)  # buffer size of 4096 bytes
        if data:
            sid = struct.unpack('H', data[0:2])[0]
            eid = struct.unpack('H', data[2:4])[0]
            size = struct.unpack('I', data[4:8])[0]
            if eid == 0:
                print("Char received: ",  struct.unpack('B', data[8:8+size])[0], sid,eid)
            elif eid ==1:
                #pass
                print("Uint received: ",  struct.unpack('I', data[8:8+size])[0], sid,eid)
            else:
                print("Error in received data")


if __name__ == "__main__":
    counter = 0
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = (UDP_IP, HOST_PORT)
    sock.bind(server_address)
    receive_thread = threading.Thread(target=udp_receive, args=(sock,))
    receive_thread.daemon = True
    receive_thread.start()
    while True:
        counter = counter + 10
        if counter > 253:
            counter = 0
        packed_data_char = pack_data_char(SERVICE_ID_FOCUS,EVENT_ID_AC_CHAR, 3, counter, counter +1, counter+2,FOCUS_OUT_CHAR_FORMAT)
        packed_data_uint = pack_data_uint(SERVICE_ID_FOCUS,EVENT_ID_AC_UINT, 4, counter*10,FOCUS_OUT_UINT_FORMAT)
        send_udp(packed_data_char)
        send_udp(packed_data_uint)
        print("Char sent: ", counter, counter +1, counter+2)
        print("Uint sent: ", counter*10)
        time.sleep(0.1)










        
import socket
import struct
import time

import numpy as np

import threading



# Define the format string for the structure (make sure it matches the data types and order)
AC_OUT_CHAR_FORMAT = 'HHIB'
AC_OUT_UINT_FORMAT = 'HHII'
FOCUS_OUT_CHAR_FORMAT = 'HHIBBB'
FOCUS_OUT_UINT_FORMAT = 'HHII'


# Define the sine wave parameters
frequency = 2  # Frequency in Hz
amplitude = 2  # Amplitude
times = np.linspace(0, 2, 1000)  # Time from 0 to 2 seconds, 1000 points
phase = 0  # Phase shift

# Generate the sine wave
sine_wave = amplitude * np.sin(2 * np.pi * frequency * times + phase)

SERVICE_ID_AC = 1
SERVICE_ID_FOCUS = 2
EVENT_ID_AC_CHAR = 0
EVENT_ID_AC_UINT = 1
EVENT_ID_FOCUS_CHAR_ARR = 0
EVENT_ID_FOCUS_UINT = 1




def pack_data_char(service_id, event_id, length,data1,data2,data3,data_format):
    packed_data = struct.pack(data_format,service_id, event_id, length,data1,data2,data3)
    return packed_data
def pack_data_uint(service_id, event_id, length,data,data_format):
    packed_data = struct.pack(data_format,service_id, event_id, length,data)
    return packed_data


UDP_IP = "127.0.0.1"  # Replace with the target IP
HOST_PORT = 43445
UDP_PORT = 43447         # Replace with the target port
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # UDP socket

def send_udp(data):
    sock.sendto(data, (UDP_IP, UDP_PORT))

def udp_receive(udp_socket):
    while True:
        # Receive data from the UDP socket
        data, client_address = udp_socket.recvfrom(4096)  # buffer size of 4096 bytes
        if data:
            sid = struct.unpack('H', data[0:2])[0]
            eid = struct.unpack('H', data[2:4])[0]
            size = struct.unpack('I', data[4:8])[0]
            if eid == 0:
                print("Char received: ",  struct.unpack('B', data[8:8+size])[0], sid,eid)
            elif eid ==1:
                #pass
                print("Uint received: ",  struct.unpack('I', data[8:8+size])[0], sid,eid)
            else:
                print("Error in received data")


if __name__ == "__main__":
    counter = 0
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = (UDP_IP, HOST_PORT)
    sock.bind(server_address)
    receive_thread = threading.Thread(target=udp_receive, args=(sock,))
    receive_thread.daemon = True
    receive_thread.start()
    while True:
        counter = counter + 10
        if counter > 253:
            counter = 0
        packed_data_char = pack_data_char(SERVICE_ID_FOCUS,EVENT_ID_AC_CHAR, 3, counter, counter +1, counter+2,FOCUS_OUT_CHAR_FORMAT)
        packed_data_uint = pack_data_uint(SERVICE_ID_FOCUS,EVENT_ID_AC_UINT, 4, counter*10,FOCUS_OUT_UINT_FORMAT)
        send_udp(packed_data_char)
        send_udp(packed_data_uint)
        print("Char sent: ", counter, counter +1, counter+2)
        print("Uint sent: ", counter*10)
        time.sleep(0.1)










        
