import socket
import time

msgFromClient = "all work and no play makes Necla a dull girl"
bytesToSend = str.encode(msgFromClient)

r3_addressPort = ("10.10.3.2", 20001)
bufferSize = 1024
t_num = 1000
s_total_cost = 0

# create a UDP socket at client side
r3_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
s_cost = []
sDelay = open("sDelay.txt", "w+")

count = 0

while count < t_num:
	# Send to server using created UDP socket
	r3_socket.sendto(bytesToSend, r3_addressPort)
	start = time.time()

	msgFromServer = r3_socket.recvfrom(bufferSize)
	end = time.time()

	msg = "Message from Server {}".format(msgFromServer[0])

	s_cost.append(float((end-start))/2)
	print('r3: ', s_cost[count])
	s_total_cost += s_cost[count]
	sDelay.write("%.17f \n" %s_cost[count])

	#print str(id) + " : " + (end - start)
	print(msg)

	count = count+1

avg = s_total_cost/t_num
sDelay.write("Total cost is : %.17f \n" %s_total_cost)
sDelay.write("Average cost is : %.17f \n" %avg)
sDelay.close()