Dir[File.dirname(__FILE__) + '/three/*.rb'].each { |f| require f }

module Three

  def self.evaluator_for(*rules)
    Three::Evaluator.new(rules)
  end

  def self.note what, details
  end

end
