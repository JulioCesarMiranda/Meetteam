class Node < ApplicationRecord
  serialize :log, Array

  has_and_belongs_to_many :neighbors,
                          class_name: 'Node',
                          join_table: 'nodes_neighbors',
                          foreign_key: 'node_id',
                          association_foreign_key: 'neighbor_id'

  attr_accessor :current_state, :proposed_state, :accepted_proposal, :active, :disconnected_nodes

  def initialize(attributes = {})
    super(attributes)
    @current_state = nil
    @proposed_state = nil
    @accepted_proposal = nil
    @active = true
    @disconnected_nodes = []
  end

  def add_neighbor(node)
    neighbors << node unless neighbors.include?(node)
  end

  def send_message(to_node, message)
    if @active && !@disconnected_nodes.include?(to_node) && neighbors.include?(to_node)
      to_node.receive_message(self, message)
      log_transition("Sent message '#{message}' to Node #{to_node.identifier}")
    elsif !@active
      log_transition("Failed to send message '#{message}' to Node #{to_node.identifier}: Node is inactive")
    elsif @disconnected_nodes.include?(to_node)
      log_transition("Failed to send message '#{message}' to Node #{to_node.identifier}: Network partition")
    else
      puts "Node #{to_node.identifier} is not a neighbor!"
    end
  end

  def receive_message(from_node, message)
    if @active
      log_transition("Received message '#{message}' from Node #{from_node.identifier}")
    else
      log_transition("Failed to receive message '#{message}' from Node #{from_node.identifier}: Node is inactive")
    end
  end

  def propose_state(state)
    if @active
      @proposed_state = state
      log_transition("Proposed state '#{state}'")
      neighbors.each do |neighbor|
        send_message(neighbor, "Proposal: #{state}")
      end
    else
      log_transition("Failed to propose state '#{state}': Node is inactive")
    end
  end

  def receive_proposal(from_node, state)
    if @active
      log_transition("Received proposal '#{state}' from Node #{from_node.identifier}")
      vote_on_proposal(state.to_i)
    else
      log_transition("Failed to receive proposal '#{state}' from Node #{from_node.identifier}: Node is inactive")
    end
  end

  def simulate_partition(disconnected_nodes)
    @disconnected_nodes = disconnected_nodes
    log_transition("Simulated network partition with nodes: #{disconnected_nodes.map(&:identifier).join(', ')}")
  end

  def simulate_failure
    @active = false
    log_transition("Simulated node failure: Node is inactive")
  end

  def retrieve_log(filter = nil)
    if filter
      log.select { |entry| entry.include?(filter) }
    else
      log
    end
  end

  private

  def achieve_consensus(state)
    agreed_count = neighbors.count { |neighbor| neighbor.accepted_proposal == state && !@disconnected_nodes.include?(neighbor) }
    if agreed_count >= (neighbors.size / 2.0).ceil
      @current_state = state
      log_transition("Consensus achieved on state '#{state}'")
    else
      log_transition("Consensus not achieved due to network partition or node failures")
    end
  end

  def log_transition(transition)
    self.log << transition
    save!
  end
end
