Dir[File.dirname(__FILE__) + '/three/*.rb'].each { |f| require f }

module Three

  def self.evaluator_for(*rules)
    Three::Evaluator.new(rules)
  end

  def self.trace what, details
    @trace_method.call(what, details) if @trace_method
  end

  def self.when_tracing &block
    @trace_method = block
  end

end
