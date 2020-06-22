import socket
import threading
import time

bufferSize  = 1024

def being_s():

	s_IP = "10.10.3.2"
	s_port = 20001

	server_msg = "all work and no play makes Necla a dull girl"
	bytesToSend = str.encode(server_msg)

	# Create a datagram socket
	serverSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

	# Bind to address and ip
	serverSocket.bind((s_IP, s_port))

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

def being_c():

	r3_addressPort = ("10.10.7.1", 20002)

	msgFromClient = "all work and no play makes Necla a dull girl"
	bytesToSend = str.encode(msgFromClient)

	bufferSize = 1024
	t_num = 1000
	s_total_cost = 0

	# create a UDP socket at client side
	r3_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
	r3_cost = []
	r3Delay = open("r3Delay.txt", "w+")

	count = 0

	while count < t_num:
		# Send to server using created UDP socket
		r3_socket.sendto(bytesToSend, r3_addressPort)
		start = time.time()

		msgFromServer = r3_socket.recvfrom(bufferSize)
		end = time.time()

		msg = "Message from Server {}".format(msgFromServer[0])

		r3_cost.append(float((end-start))/2)
		print('r3: ', r3_cost[count])
		s_total_cost += r3_cost[count]
		r3Delay.write("%.17f \n" %r3_cost[count])

		#print str(id) + " : " + (end - start)
		print(msg)

		count = count+1

	avg = s_total_cost/t_num
	r3Delay.write("Total cost is : %.17f \n" %s_total_cost)
	r3Delay.write("Average cost is : %.17f \n" %avg)
	r3Delay.close()


thread_server = threading.Thread(target = being_s)
thread_client = threading.Thread(target = being_c)

thread_client.start()
thread_server.start()