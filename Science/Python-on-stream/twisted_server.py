from twisted.internet import protocol,reactor
class Pong(protocol.Protocol):
	def data_received(self, data):
		print("Client:", data);
		if data.startswith("Ping!"):
			response = "Pong!";
		else:
			response = data + "password?";
		print("Server:", response);
	pass	
class PongFactory(protocol.Factory):
	def buildProtocol(self, addr):
		return Ping;
reactor.listenTCP(8000, PongFactory())
reactor.run()
