## Three - is a super-ultra simple authorization gem for ruby! 

[![Build Status](https://travis-ci.org/darrencauthon/three.png?branch=master)](https://travis-ci.org/darrencauthon/three)
[![Code Climate](https://codeclimate.com/github/darrencauthon/three.png)](https://codeclimate.com/github/darrencauthon/three)
[![Coverage Status](https://coveralls.io/repos/darrencauthon/three/badge.png)](https://coveralls.io/r/darrencauthon/three)

_based on clear ruby it can be used for rails 2 & 3 or any other framework_

### Installation

```ruby
  gem install three
```


### QuickStart

4 steps:


1. Create an object with an "allowed" method. 

This method will receive two arguments, the subject (the object we are checking the rules for) and a target (optionally passed as nil, 

    ```ruby
    class CarDrivingPrivileges
      def allowed minor, car
        if car.paid_off? && minor.insured?
          [:can_drive_car_to_movies, :can_drive_car_to_work]
        elsif minor.chaperoned?
          [:can_drive_car_home]
        else
          []
        end
      end
    end
    ```
2. Create a judge to enforce the rules

    ```ruby
      rules = CarDrivingPrivileges.new
      judge = Three.judge_enforcing rules
    ```

3. Now you can use the judge to determine the abilities of the objects in question.

    ```ruby
    teenager = Person.new(age: 16, insured: false, chaperoned: true)
    car      = Car.new(paid_off: false)
    judge.allowed?(teenager, :can_drive_car_home, car) # true
    ```

### Examples

```ruby 

class PawnRules

  def self.allowed(piece, square)

    # if the rules do not apply, return nothing
    # yours checks here may start with a
    # verification of the type passed in
    return [] unless piece.is_a_pawn?

    return [] if square.is_covered_by_friendly_piece?

    return [] if piece.position_is_protecting_from_check

    rights = []

    rights << :can_move_to if square.is_one_space_before(piece.square)
    rights << :can_promote if square.is_at_the_end_of_the_board?

    rights

  end

end

# create judge
judge = Three.judge_for([PawnRules.new, KingRules.new]) # QueenRules, etc...

possible_moves = []
chess_board.squares.each do |square|
  my_pieces.each do |chess_piece|
    if judge.allowed? chess_piece, :can_move_to, square
      possible_moves << [chess_pice, square]
    end
  end
end

```
