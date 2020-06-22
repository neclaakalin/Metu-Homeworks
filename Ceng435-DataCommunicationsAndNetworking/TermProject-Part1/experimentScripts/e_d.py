import socket

bufferSize  = 1024
r3_IP = "10.10.7.1"
r3_port = 20002

server_msg = "all work and no play makes Necla a dull girl"
bytesToSend = str.encode(server_msg)

# Create a datagram socket
serverSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

# Bind to address and ip
serverSocket.bind((r3_IP, r3_port))

print("Server is ready to listen...")

# Listen for incoming datagrams
while(True):

	bytesAddressPair = serverSocket.recvfrom(bufferSize)
	message = bytesAddressPair[0]
	address = bytesAddressPair[1]

	client_msg = "Message from Client:{}".format(message)
	clientIP  = "Client IP Address:{}".format(address)

	print(client_msg)
	print(clientIP)

	# Sending a reply to client
	serverSocket.sendto(bytesToSend, address)