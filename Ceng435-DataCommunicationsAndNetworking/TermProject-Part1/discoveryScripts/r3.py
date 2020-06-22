import socket
import time
import threading

msgFromClient = "All work and no play makes Necla a dull girl"
bytesToSend = str.encode(msgFromClient)
s_addressPort = ("10.10.3.1", 21001)
d_addressPort = ("10.10.7.1", 21011)
r2_addressPort = ("10.10.6.1", 21021)
bufferSize = 1024
s_cost = []
d_cost = []
r2_cost = []
t_num = 1000

# create a UDP socket at client side
s_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
d_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
r2_socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

def server(addressPort, socket, id):
	# opens a txt file, creates one if not exists, renews if already exists
	r3_to_s_costs = open("r3_to_s_costs.txt", "w+")
	r3_to_d_costs = open("r3_to_d_costs.txt", "w+")
	r3_to_r2_costs = open("r3_to_r2_costs.txt", "w+")

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
			r3_to_s_costs.write("%.17f \n" %s_cost[count])

		elif id == 'd':
			d_cost.append(float((end-start))/2)
			print('d: ', d_cost[count])
			r3_to_d_costs.write("%.17f \n" %d_cost[count])

		elif id == 'r2':
			r2_cost.append(float((end-start))/2)
			print('r2: ', r2_cost[count])
			r3_to_r2_costs.write("%.17f \n" %r2_cost[count])

		#print str(id) + " : " + (end - start)
		print(msg)

		count = count+1

	# closes the .txt files
	r3_to_s_costs.close()
	r3_to_d_costs.close()
	r3_to_r2_costs.close()

thread_s = threading.Thread(target = server, args = (s_addressPort, s_socket, 's'))
thread_d = threading.Thread(target = server, args = (d_addressPort, d_socket, 'd'))
thread_r2 = threading.Thread(target = server, args = (r2_addressPort, r2_socket, 'r2'))

thread_s.start()
thread_d.start()
thread_r2.start()

time.sleep(300)

i = 0

s_total_c = 0
d_total_c = 0
r2_total_c = 0

while i < t_num:
	s_total_c += s_cost[i]
	d_total_c += d_cost[i]
	r2_total_c += r2_cost[i]

	i += 1

print("s total cost before division is: %.17f \n" %s_total_c)
print("d total cost before division is: %.17f \n" %d_total_c)
print("r2 total cost before division is: %.17f \n" %r2_total_c)

s_total_c /= t_num
d_total_c /= t_num
r2_total_c /= t_num

print("s total cost is: %.17f \n" %s_total_c)
print("d total cost is: %.17f \n" %d_total_c)
print("r2 total cost is: %.17f \n" %r2_total_c)