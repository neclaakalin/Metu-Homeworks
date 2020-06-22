import socket
import threading

bufferSize = 1024

def server(localIP, localPort):

	msgFromServer = "All work and no play makes Necla a dull girl"

	bytesToSend = str.encode(msgFromServer)

	# Create a datagram socket
	UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

	# Bind to address and ip
	UDPServerSocket.bind((localIP, localPort))

	print("Server is ready to listen...")

	# Listen for incoming datagrams
	while(True):

		bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)

		message = bytesAddressPair[0]

		address = bytesAddressPair[1]

		clientMsg = "Message from Client:{}".format(message)
		clientIP  = "Client IP Address:{}".format(address)
		
		print(clientMsg)
		print(clientIP)
		# Sending a reply to client
		UDPServerSocket.sendto(bytesToSend, address)


thread_r1 = threading.Thread(target = server, args = ("10.10.4.2", 20011))
thread_r2 = threading.Thread(target = server, args = ("10.10.5.2", 22011))
thread_r3 = threading.Thread(target = server, args = ("10.10.7.1", 21011))

thread_r1.start()
thread_r2.start()
thread_r3.start()