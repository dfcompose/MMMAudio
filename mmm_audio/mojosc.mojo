from net import UDPSocket, SocketAddress
from std.memory import bitcast


struct OSCClient():
    var udp_socket : UDPSocket
    var target_addr : SocketAddress
    var port : UInt16
    var address : String
    def __init__(out self, target_ip : String = "127.0.0.1", port: UInt16 = 57120) raises:
        
        var ip = target_ip.split(".")
        var ip_arr = Array[UInt8, 4](fill=0)
        for i, val in enumerate(ip):
            ip_arr[i] = Int(val).cast[DType.uint8]()
        
        self.address = target_ip
        self.port = port
        self.udp_socket = UDPSocket("127.0.0.1", 0)
        
        self.target_addr = SocketAddress.v4(ip_arr[0], ip_arr[1], ip_arr[2], ip_arr[3], port)

    def set_target_ip_address(mut self, target_ip: String) raises:
        var ip = target_ip.split(".")
        var ip_arr = Array[UInt8, 4](fill=0)
        for i, val in enumerate(ip):
            ip_arr[i] = Int(val).cast[DType.uint8]()
        self.address = target_ip
        self.target_addr = SocketAddress.v4(ip_arr[0], ip_arr[1], ip_arr[2], ip_arr[3], self.port)
    
    def set_target_port(mut self, port: UInt16) raises:
        self.port = port
        var ip = self.address.split(".")
        var ip_arr = Array[UInt8, 4](fill=0)
        for i, val in enumerate(ip):
            ip_arr[i] = Int(val).cast[DType.uint8]()
        self.target_addr = SocketAddress.v4(ip_arr[0], ip_arr[1], ip_arr[2], ip_arr[3], self.port)

    def close(mut self):
        self.udp_socket.close()


    def send_osc[address: String](self, vals: List[Int]) raises:
        var addr_byte_array : Array[Byte, len(address.as_bytes()) + (4 - len(address.as_bytes()) % 4)] = Array[Byte, len(address.as_bytes()) + (4 - len(address.as_bytes()) % 4)](fill=0)
        var tags = List[UInt8]()
        
        
        tags.resize(len(vals) + ( 4 - len(vals) % 4), 0)
        for i in range(len(vals) + 1):
            tags[i] = 105
        tags[0] = 44
        
        while len(tags) % 4 != 0:
            tags.append(0)
        
        comptime for i, byte in enumerate(address.as_bytes()):
                addr_byte_array[i] = byte

        

        while len(tags) % 4 != 0:
            tags.append(0)

        var message = List[UInt8]() 
        # message.resize(len(addr_byte_array), 0)
        _ = [message.append(i) for i in addr_byte_array]
        message = message + [i for i in tags]
        # message += [0,0,0,0]
        

        for val in vals:
            var bytes = bitcast[DType.uint8, 4](Int32(val))
            bytes = bytes.shuffle[3, 2, 1, 0]()
            message.append(bytes[0])
            message.append(bytes[1])
            message.append(bytes[2])
            message.append(bytes[3])

       
        self.udp_socket.send_to(message, self.target_addr)


    def send_osc[address: String](self, vals: List[Float64]) raises:
        var addr_byte_array : Array[Byte, len(address.as_bytes()) + (4 - len(address.as_bytes()) % 4)] = Array[Byte, len(address.as_bytes()) + (4 - len(address.as_bytes()) % 4)](fill=0)
        var tags = List[UInt8]()
        
        
        tags.resize(len(vals) + ( 4 - len(vals) % 4), 0)
        for i in range(len(vals) + 1):
            tags[i] = 102
        tags[0] = 44
        if len(vals) + (4 - len(vals) % 4) == 0:
            tags.append(0)
            tags.append(0)
            tags.append(0)
            tags.append(0)
        
        comptime for i, byte in enumerate(address.as_bytes()):
                addr_byte_array[i] = byte

        var message = List[UInt8]() 
        # message.resize(len(addr_byte_array), 0)
        _ = [message.append(i) for i in addr_byte_array]
        message = message + [i for i in tags]
        # message += [0,0,0,0]
        

        for val in vals:
            var bytes = bitcast[DType.uint8, 4](Float32(val))
            bytes = bytes.shuffle[3, 2, 1, 0]()
            message.append(bytes[0])
            message.append(bytes[1])
            message.append(bytes[2])
            message.append(bytes[3])
        
        self.udp_socket.send_to(message, self.target_addr)
    