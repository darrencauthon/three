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

      describe "the error checking is disabled" do

        it "should throw if the rule returns an error" do

          failing_rule = Object.new
          failing_rule.stubs(:allowed).raises 'error'
          failing_rule.stubs(:prevented).returns []

          begin
            evaluator = Three.evaluator_for(failing_rule)
            evaluator.rescue_errors = false
            evaluator.allowed? nil, :something
          rescue
            error_hit = true
          end

          error_hit.must_equal true
            
        end

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

      describe "the error checking is disabled" do

        it "should throw if the prevented rule returns an error" do

          failing_rule = Object.new
          failing_rule.stubs(:allowed).returns [:sigh]
          failing_rule.stubs(:prevented).raises 'k'

          begin
            evaluator = Three.evaluator_for(failing_rule)
            evaluator.rescue_errors = false
            evaluator.allowed? nil, :sigh
          rescue
            error_hit = true
          end

          error_hit.must_equal true
            
        end

      end

    end

  end

  describe "noting important things" do

    let(:the_subject) { Object.new }
    let(:the_target)  { Object.new }
    let(:permission)  { SecureRandom.uuid.to_sym }

    it "should note the allowed permission build-up" do
      good_rule = Object.new.tap do |r|
                    r.stubs(:allowed).returns [permission]
                  end

      Three.expects(:note).with do |what, stuff|
        what.must_equal :allowed
        stuff[:rule].must_be_same_as good_rule
        stuff[:permissions].must_equal [permission]
        stuff[:subject].must_be_same_as the_subject
        stuff[:target].must_be_same_as the_target
      end
      Three.evaluator_for(good_rule).allowed?(the_subject, permission, the_target)
    end

  end

end
