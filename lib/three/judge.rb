module Three

  class Judge

    def initialize(rules)
      @rules = a_single_array_was_provided?(rules) ? rules[0] : rules
    end

    def allowed? subject, permissions_to_check, target = nil
      permissions = convert_to_an_array_if_its_not permissions_to_check
      these_permissions_are_allowed_for? permissions, subject, target
    end

    private

    def rules
      @rules
    end

    def convert_to_an_array_if_its_not potential_array
      this_is_an_array?(potential_array) ? potential_array : [potential_array]
    end

    def these_permissions_are_allowed_for? permissions, subject, target
      permissions.all? { |p| permission_included? subject, p, target }
    end

    def a_single_array_was_provided? rules
      rules.count == 1 && this_is_an_array?(rules[0])
    end

    def this_is_an_array? thing
      thing.respond_to? :each
    end

    def permission_included? subject, permission_to_check, target
      allowed_permissions_for(subject, target).include? permission_to_check.to_s
    end

    def allowed_permissions_for subject, target
      all_permissions       = all_permissions_for subject, target
      permissions_to_reject = permissions_to_reject_for subject, target

      all_permissions - permissions_to_reject
    end

    def all_permissions_for subject, target
      permissions = rules.map { |r| execute_rule r, :allowed, subject, target }
      flatten_permissions permissions
    end

    def permissions_to_reject_for subject, target
      permissions = rules.map { |r| execute_rule r, :prevented, subject, target }
      flatten_permissions permissions
    end

    def execute_rule rule, method, subject, target
      begin
        begin
          # try sending a target first
          rule.send(method, subject, target)
        rescue
          # if that fails, try sending just the subject
          rule.send(method, subject)
        end
      rescue
        # if everything fails, just return nothing
        []
      end
    end

    def flatten_permissions permissions
      permissions.flatten.map { |a| a.to_s }
    end

  end

end
