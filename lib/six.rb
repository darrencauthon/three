Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

module Six

  def self.judge_enforcing(*rules)
    Six::Judge.new(rules)
  end

end
