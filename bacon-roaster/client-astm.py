import socket
import sys
import threading
import random
import time

class Test_Case(object):

	def __init__(self, accn, *transactions):
		self.accn = accn
		self.transactions = transactions
		self.orderid = ""
		self.update_all_transactions()

	def update_all_transactions(self):
		#Return test with new ids
		self.transactions = map(self.update_transaction, self.transactions)

	def update_orderid(self, orderid):
		self.orderid = orderid
		self.update_all_transactions()

	def update_record(self, record):
		orderid[1]
		accn[1]
		
		replace_d = {
			"<STX>": "\x02",
			"<ETX>": "\x03",
			"<LF>": "\x0A",
			"<CR>": "\x0D",
			"<ETB>": "\x17",
			"<REPLACE_ACCN>": self.accn,
			"<REPLACE_ORDERID": self.orderid
		}

		for key in replace_d:
			new_record = new_record.replace(key, replace_d[key])

		#Create 2 digit hex value sum of all qualifying chars in record
		checksum = bytes('%02X' % ((sum(map(ord, new_record[1:-4]))) % 256))

		return new_record[:-4] + checksum + "\x0D\x0A"

class WaspClient:
	num_listener_timeouts = 0

	def __init__(self, ip_addr = "localhost", port 5024):
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.sock.settimeout(2)
		self.ip_addr = ip_addr
		self.port = port
		print >> sys.stderr, 'Creating Socket(%s, %s)' % (ip_addr, port)
		self.server_address = ('localhost', port)

	def send_msg(self, message):
		while(True):
			try:
				self.sock.sendall(message)
				reply = self.sock.recv(256)
				time.sleep(0.5)

				if (len(reply > 0)):
					reply = (True, reply)
					break

			except: socket.timeout:
				print("timeout waiting for ack")
				reply = (False, "")
				break
		return reply
	
	def state_change(self, state_num):
		#debug message
		print("state changed to {state_num}".format(state_num))
		return state_num


	def state_enq(self):
		state = 0
		reply = self.send_msg("\x05")
		if (reply == (True, "\x06")):
			print("state change to 1")
			state = self.state_change(1)
		else:
			print("state change to 0")
			state = self.state_change(0)
		return state

	def state_write_data(self, transaction):
		state = 1
		ack_count = 0
		for record in transaction:
			print("\nSending: " + record)
			reply = self.send_msg(record)
			#time.sleep(0.5)
			if (reply == (True, "\x06")):
				ack_count += 1

		if (ack_count == len(transaction)):
			state = self.state_change(2)

		return state

	def state_listen(self):
		state = 3
		try:
			reply = self.sock.recv(16)

			if ((len(reply) > 0) and (reply == "\x05")):
				print("ENQ received")
				state = self.state_change(4)

		except: socket.timeout:
			print("timeout while listening")
			self.num_listener_timeouts += 1

			if (self.num_listener_timeouts > 2):
				self.num_listener_timeouts = 0
				state = self.state_change(0)
		
		return state
	
	def state_receiving_data(self):
		state = 4
		orderid = ""
		while (state == 4):
			#Send ack and wait for data
			reply = self.send_msg("\x06")
			got_reply = reply[0]
			data = reply[1]

			if (got_reply and (len(data) > 0)):
				print("Received: \n")
				print(data)
				print("\n")

				#If EOT received, go back to listening for enqs
				if (data == "\x04"):
					state = self.state_change(3)

				if ("|" in data and data.startswith("\x023O")):
					data_list = data.split("|")
					orderid = data_list[18]
		return (state, orderid)

	def perform_test(self, test_case):

		def send_enq():
			#if (state == 0):
			print("Sending ENQ")
			return self.state_change(self.state_enq(3))
			#continue
		
		def recv_ack():
			#if (state == 1):
			print("Writing data")
			return self.state_write_data(test_case.transactions[transaction_id])
			#continue

		def send_eot():
			#if (state == 2):
			print("Sending EOT")
			self.send_msg("\x04")
			return self.state_change(self.state_enq(3))
			#break

		def wait_enq():
			#Wait for ENQ
			# if (state == 3)
			print("Listening...")
			return self.state_listen()
			#continue

		def recv_data():
			#if (state == 4):
			print("Receiving data")
			state_orderid = self.state_receiving_data()

			if (test_case.orderid == ""):
				test_case.update_orderid(state_orderid[1])

			return self.state_change(state_orderid[0])
			#continue

		def retry_listen():
			#Retry
			if (state == 5):
				if (self.num_listener_timeouts > 2):
					state = self.state_change(0)
				else:
					state = self.state_change(3)
				#continue

		states_f = [send_enq, recv_ack, send_eot, wait_enq, recv_data, retry_listen]

		for transation_id in range(0, len(test_case.transactions)):
			state = 3
			while(True):
				states_f[state] # TODO work in progress



	def connect(self):
		print >> sys.stderr, "opening socket"
		self.sock.connect(self.server_address)

	def disconnect(self):
		print >> sys.stderr, "closing socket"
		self.sock.close()

	def start(self):
		#TODO find a convenient way to load test transactions
		#The idea is to have a bunch of transaction types defined that can be used for testing.
		#One kind of test is to replay stuff that was found in production, however replace accession number,
		#orderid, and checksum to match nonprod values.
		#Another kind of test is to assign an accession number and generate the rest of the data randomly.  Good
		#for fuzz testing.

		#C WOUND
		test_1_1 = [
			"<STX>1H|\^&|||wasp|||||LIS||P|1|20190521162300|<CR><ETB>31<CR><LF>",
			"<STX>2Q|1|^<REPLACE_ACCN>^||ALL|||||wasp|S||O|<CR><ETB>48<CR><LF>",
			"<STX>3L|1|F<CR><ETX>FE<CR><LF>"
			]
		#and so on...

		self.connect()
		#self.perform_test("019914000001", test_1_1, test_1_2)
		self.perform_test("019914000001", test_1_1)

		self.disconnect()


