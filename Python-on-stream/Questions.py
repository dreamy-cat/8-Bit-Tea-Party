# 8-Bit Tea Party.

import sys
import string
import random

class Event():
	items = ["Small heal", "Small poison", "Medium heal", "Medium poison", "Large heal", "Large poison"]
	chances = [45, 65, 35, 75, 20, 80]
	points = [10, -8, 20, -25, 35, -50]
	def __init__(self):
		print("Event constructor and default data for items.")
		print("{0:16s} {1:8s} {2:8s}".format("Items:", "Chance:", "Points:"))
		i = 0
		while i < len(self.items):
			print("{0:16s} {1:<8d} {2:<8d}".format(self.items[i], self.chances[i], self.points[i]))
			i += 1
		pass
	def next_event(self):
		event_type = random.randint(0, len(self.items) - 1);
		item_gen = list()
		if event_type % 2 == 0:
			rnd_heal = random.randint(0, 100);
			if rnd_heal < self.chances[event_type]:
				item_gen.append(self.items[event_type])
				item_gen.append(self.points[event_type])
		else:
			rnd_poison = random.randint(0, 100)
			if rnd_poison < self.chances[event_type]:
				item_gen.append(self.items[event_type])
				item_gen.append(self.points[event_type])
		return item_gen
		pass
	pass

# Simple model with events.
print("Model with simple events.")
counter = 0; counter_limit = 10; health = 100; events = Event()
print("\nStarting model counter.")
while counter < counter_limit:
	print("Model counter:", counter, ", health:", health)
	items = events.next_event()
	print("List of random item:", items)
	if items:
		health += items[-1]
	counter += 1


