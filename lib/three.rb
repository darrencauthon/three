Dir[File.dirname(__FILE__) + '/three/*.rb'].each { |f| require f }

module Three

  def self.judge_enforcing(*rules)
    Three::Judge.new(rules)
  end

end
