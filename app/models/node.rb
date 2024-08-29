class Node < ApplicationRecord
  serialize :log, Array
  attr_accessor :neighbors

  after_initialize :set_defaults

  def set_defaults
    self.active = true if self.active.nil?
    self.neighbors ||= []
  end

  def add_neighbor(node)
    self.neighbors << node
  end

  def send_message(message, target)
    if target.neighbors.include?(self) && target.active
      target.receive_message(identifier, message)
      log_message("Sent: '#{message}' to Node #{target.identifier}")
    end
  end

  def receive_message(from, message)
    if active
      log_message("Received: '#{message}' from Node #{from}")
      handle_message(message) # Aquí añadir tu lógica de consenso
    end
  end

  def propose_state(state)
    if active
      self.current_state = state
      save
      neighbors.each { |neighbor| send_message("Propose #{state}", neighbor) }
    end
  end

  def simulate_partition(partitioned_nodes)
    partitioned_nodes.each { |node| neighbors.delete(node) }
  end

  def log_message(message)
    self.log << message
    save
  end

  def retrieve_log
    log
  end

  private

  def handle_message(message)
    # Implementa aquí la lógica del algoritmo de consenso
  end
end
