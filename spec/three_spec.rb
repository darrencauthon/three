require_relative 'spec_helper'

describe Three do

  describe "allowed?" do

    describe "there are no rules" do

      let(:abilities) { Three::Evaluator.new([]) }

      it "should return false" do
        abilities.allowed?(nil, :does_not_matter).must_equal false
        abilities.allowed?(Object.new, :something_else).must_equal false
      end

    end

    [:one, :two].each do |permission|

      describe "one rule that returns one permission" do

        let(:abilities) { Three.evaluator_for([rule]) }

        let(:subject) { Object.new }

        let(:rule) do
          o = Object.new
          o.stubs(:allowed).with(subject, nil).returns [permission]
          o
        end

        it "should return true for the allowed permission" do
          abilities.allowed?(subject, permission).must_equal true
        end

        it "should return false for other permissions" do
          abilities.allowed?(subject, :something_else).must_equal false
          abilities.allowed?(subject, :another_thing).must_equal false
        end

        describe "with a target" do

          let(:target) { Object.new }

          before do
            rule.stubs(:allowed).with(subject, target).returns [permission]
          end

          it "should return true for the allowed permission" do
            abilities.allowed?(subject, permission).must_equal true
          end

          it "should return true if asked for the permission in an array" do
            abilities.allowed?(subject, [permission]).must_equal true
          end

          it "should return false for other permissions" do
            abilities.allowed?(subject, :something).must_equal false
            abilities.allowed?(subject, :another).must_equal false
          end

        end

      end

    end

    describe "one rule that returns two permissions" do

      let(:abilities) { Three.evaluator_for([rule]) }

      let(:subject) { Object.new }

      let(:rule) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange, :banana]
        o
      end

      it "should return true if asked for either, alone" do
        abilities.allowed?(subject, :orange).must_equal true
        abilities.allowed?(subject, :banana).must_equal true
      end

      it "should return true if asked for both at the same time" do
        abilities.allowed?(subject, [:orange, :banana]).must_equal true
      end

      it "should return true if asked for one and another that does not match" do
        abilities.allowed?(subject, [:orange, :apple]).must_equal false
        abilities.allowed?(subject, [:pear, :banana]).must_equal false
      end

      it "should return false for other permissions" do
        abilities.allowed?(subject, :apple).must_equal false
        abilities.allowed?(subject, :pear).must_equal false
      end

    end

    describe "two rules that return one permission each" do

      let(:abilities) { Three.evaluator_for([rule1, rule2]) }

      let(:subject) { Object.new }

      let(:rule1) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange]
        o
      end

      let(:rule2) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:banana]
        o
      end

      it "should return true if asked for either, alone" do
        abilities.allowed?(subject, :orange).must_equal true
        abilities.allowed?(subject, :banana).must_equal true
      end

      it "should return true if asked for both at the same time" do
        abilities.allowed?(subject, [:orange, :banana]).must_equal true
      end

      it "should return true if asked for one and another that does not match" do
        abilities.allowed?(subject, [:orange, :apple]).must_equal false
        abilities.allowed?(subject, [:pear, :banana]).must_equal false
      end

      it "should return false for other permissions" do
        abilities.allowed?(subject, :apple).must_equal false
        abilities.allowed?(subject, :pear).must_equal false
      end

    end

    describe "rejecting permissions" do

      let(:abilities) { Three.evaluator_for([rule1, rule2]) }

      let(:subject) { Object.new }

      let(:rule1) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange, :banana]
        o.stubs(:prevented).with(subject, nil).returns [:apple]
        o
      end

      let(:rule2) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:apple, :pear]
        o.stubs(:prevented).with(subject, nil).returns [:banana]
        o
      end

      it "should return false for the permissions that are prevented" do
        abilities.allowed?(subject, :banana).must_equal false
        abilities.allowed?(subject, :apple).must_equal false
      end

      it "should return true for the permissions that are not prevented" do
        abilities.allowed?(subject, :pear).must_equal true
        abilities.allowed?(subject, :orange).must_equal true
      end

      describe "with a target" do

        let(:target) { Object.new }

        before do
          rule1.stubs(:allowed).with(subject, target).returns [:orange, :banana]
          rule1.stubs(:prevented).with(subject, target).returns [:apple]

          rule2.stubs(:allowed).with(subject, target).returns [:apple, :pear]
          rule2.stubs(:prevented).with(subject, target).returns [:banana]
        end

        it "should return false for the permissions that are prevented" do
          abilities.allowed?(subject, :banana, target).must_equal false
          abilities.allowed?(subject, :apple, target).must_equal false
        end

        it "should return true for the permissions that are not prevented" do
          abilities.allowed?(subject, :pear, target).must_equal true
          abilities.allowed?(subject, :orange, target).must_equal true
        end
      end

    end

    describe "alternate constructor" do

      let(:abilities) { Three.evaluator_for(rule1, rule2) }

      let(:subject) { Object.new }

      let(:rule1) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange, :banana]
        o.stubs(:prevented).with(subject, nil).returns [:apple]
        o
      end

      let(:rule2) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:apple, :pear]
        o.stubs(:prevented).with(subject, nil).returns [:banana]
        o
      end

      it "should return false for the permissions that are prevented" do
        abilities.allowed?(subject, :banana).must_equal false
        abilities.allowed?(subject, :apple).must_equal false
      end

      it "should return true for the permissions that are not prevented" do
        abilities.allowed?(subject, :pear).must_equal true
        abilities.allowed?(subject, :orange).must_equal true
      end

    end

    describe "no rules provided" do
      it "should return false for everything" do
        abilities = Three::Evaluator.new([])
        abilities.allowed?(Object.new, :anything).must_equal false
        abilities.allowed?(Object.new, :anything, Object.new).must_equal false
      end
    end

  end

  describe "tracing" do

    before { Three.instance_eval { @trace_method = nil } }
    after  { Three.instance_eval { @trace_method = nil } }

    it "should do nothing by default" do
      Three.trace nil, nil
    end

    it "should allow me to register a new way to handle nothing" do
      one, two, thing = Object.new, Object.new, Object.new
      Three.when_tracing { |a, b| [a, b, thing] }

      result = Three.trace one, two
      result[0].must_be_same_as one
      result[1].must_be_same_as two
      result[2].must_be_same_as thing
    end

  end

end
