import socket
import threading
import time

bufferSize  = 1024

def being_s():
	def server(localIP, localPort, client):

		msgFromServer       = "All work and no play makes Necla a dull girl"
		bytesToSend         = str.encode(msgFromServer)

		# Create a datagram socket
		UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

		# Bind to address and ip
		UDPServerSocket.bind((localIP, localPort))

		print("Server is ready for " + client)

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


	thread_r1 = threading.Thread(target = server, args = ("10.10.8.2", 20021, 'r1'))
	thread_r3 = threading.Thread(target = server, args = ("10.10.6.1", 21021, 'r3'))

	thread_r1.start()
	thread_r3.start()

def being_c():
	msgFromClient = "All work and no play makes Necla a dull girl"
	bytesToSend = str.encode(msgFromClient)

	s_addressPort = ("10.10.2.2", 22001)
	d_addressPort = ("10.10.5.2", 22011)

	s_cost = []
	d_cost = []

	t_num = 1000

	# create a UDP socket at client side
	s_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
	d_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

	def serv(addressPort, socket, id):
		# opens a txt file, creates one if not exists, renews if already exists
		r2_to_s_costs = open("r2_to_s_costs.txt", "w+")
		r2_to_d_costs = open("r2_to_d_costs.txt", "w+")

		count = 0
		while count < t_num:
		# Send to server using created UDP socket
			socket.sendto(bytesToSend, addressPort)
			start = time.time()

			msgFromServer = socket.recvfrom(bufferSize)
			end = time.time()

			msg = "Message from Server {}".format(msgFromServer[0])

			if id == 's':
				s_cost.append(float((end-start))/2)
				print('s: ', s_cost[count])
				r2_to_s_costs.write("%.17f \n" %s_cost[count])

			elif id == 'd':
				d_cost.append(float((end-start))/2)
				print('d: ', d_cost[count])
				r2_to_d_costs.write("%.17f \n" %d_cost[count])

			#print str(id) + " : " + (end - start)
			print(msg)

			count = count+1

		# closes the .txt files
		r2_to_s_costs.close()
		r2_to_d_costs.close()

	thread_s = threading.Thread(target = serv, args = (s_addressPort, s_socket, 's'))
	thread_d = threading.Thread(target = serv, args = (d_addressPort, d_socket, 'd'))
	
	thread_s.start()
	thread_d.start()

	time.sleep(300)

	i = 0

	s_total_c = 0
	d_total_c = 0

	while i < t_num:
		s_total_c += s_cost[i]
		d_total_c += d_cost[i]

		i += 1

	print("s total cost before division is: %.17f \n" %s_total_c)
	print("d total cost before division is: %.17f \n" %d_total_c)

	s_total_c /= t_num
	d_total_c /= t_num

	print("s total cost is: %.17f \n" %s_total_c)
	print("d total cost is: %.17f \n" %d_total_c)


thread_server = threading.Thread(target = being_s)
thread_client = threading.Thread(target = being_c)

thread_client.start()
thread_server.start()