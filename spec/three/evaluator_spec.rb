require_relative '../spec_helper'

describe Three::Evaluator do

  describe "rescuing failures" do

    describe "allowed" do

      it "should return false if the rule returns an error" do

        good_rule, missing_rule, failing_rule = Object.new, Object.new, Object.new
        good_rule.stubs(:allowed).returns [:something]
        missing_rule.stubs(:allowed).returns [:something_else]
        failing_rule.stubs(:allowed).raises 'error'

        Three.evaluator_for(good_rule).allowed?(nil, :something).must_equal true
        Three.evaluator_for(missing_rule).allowed?(nil, :something).must_equal false
        Three.evaluator_for(failing_rule).allowed?(nil, :something).must_equal false
          
      end

    end

    describe "prevented" do

      it "should return not block the permission if it returns an error" do

        good_rule, bad_rule = Object.new, Object.new

        good_rule.stubs(:allowed).returns [:apple]
        good_rule.stubs(:prevented).returns [:apple]

        bad_rule.stubs(:allowed).returns [:apple]
        bad_rule.stubs(:prevented).raises 'k'

        Three.evaluator_for(good_rule).allowed?(nil, :apple).must_equal false
        Three.evaluator_for(bad_rule).allowed?(nil, :apple).must_equal true
          
      end

    end


  end

end
