node1 = Node.create(identifier: 1)
node2 = Node.create(identifier: 2)
node3 = Node.create(identifier: 3)

node1.add_neighbor(node2)
node1.add_neighbor(node3)
node2.add_neighbor(node1)
node2.add_neighbor(node3)
node3.add_neighbor(node1)
node3.add_neighbor(node2)

node1.propose_state(1)
node2.propose_state(2)
node3.simulate_partition([node1])
node2.propose_state(3)

Node.all.each { |node| puts "Node #{node.identifier} Log: #{node.retrieve_log.join(', ')}" }

