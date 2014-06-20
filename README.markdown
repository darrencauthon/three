## Three - an even smaller, tinier simple authorization gem for ruby

[![Build Status](https://travis-ci.org/darrencauthon/three.png)](https://travis-ci.org/darrencauthon/three)
[![Code Climate](https://codeclimate.com/github/darrencauthon/three.png)](https://codeclimate.com/github/darrencauthon/three)
[![Coverage Status](https://coveralls.io/repos/darrencauthon/three/badge.png)](https://coveralls.io/r/darrencauthon/three)

This gem started as a minor fork of [six](https://github.com/randx/six), a neat, tiny authorization gem.  I used six and liked it, but as small was it was I found that I needed maybe half of its code and features. So here is *three*.

**three** is a small authentication library, focused on only a few needs:

1. Provide an open/closed method of constructing rules,
2. Provide a way to remove permissions, and
3. Do it as simply as possible.

### Installation

```ruby
  gem install three
```

### Usage

Here's the simplest working example... a set of rules that apply for all

```ruby
# make an object with an "allowed" method that returns an array of permissions
module Rules
  def self.allowed _, _
    [:edit, :delete]
  end
end

# create an evaluator that can be used to evaluate rules
evaluator = Three.evaluator_for Rules

# use the evaluator to determine what's allowed or not

evaluator.allowed? nil, :edit   # true
evaluator.allowed? nil, :close  # false
evaluator.allowed? nil, :delete # true
```

Unfortunately, that's not a very realistic example. We'll almost always want to evaluate the rules based on some sort of subject:

```ruby
module AdminRules
  def self.allowed user, _
    return [] unless user.admin?
    [:edit, :delete]
  end
end

evaluator = Three.evaluator_for AdminRules

admin_user   = User.new(admin: true)
not_an_admin = User.new(admin: false)

evaluator.allowed? admin_user, :edit        # true
evaluator.allowed? not_an_admin_user, :edit # false
```

See?  The array of permissions returned by the "allowed" method are used to determine if a user can do something.

The rules can be compounded, like so:


```ruby
module AdminRules
  def self.allowed user, _
    return [] unless user.admin?
    [:edit, :delete]
  end
end

module UserRules
  def self.allowed user, _
    return [] if user.admin?
    [:view_my_account]
  end
end

evaluator = Three.evaluator_for(AdminRules, UserRules)

admin_user   = User.new(admin: true)
not_an_admin = User.new(admin: false)

evaluator.allowed? admin_user, :edit        # true
evaluator.allowed? not_an_admin_user, :edit # false

evaluator.allowed? admin_user, :view_my_account        # false
evaluator.allowed? not_an_admin_user, :view_my_account # true
```

But what about that trailing "_" variable?  That's used as an optional target, which you can use to return permissions based on the relationship between the two arguments:

```ruby
module MovieRules
  def self.allowed user, movie
    if user.is_a_minor? and movie.is_rated_r
      []
    else
      [:can_buy_the_ticket]
    end
  end
end

evaluator = Three.evaluator_for MovieRules

minor       = User.new(minor: true)
not_a_minor = User.new(minor: false)

scary_movie = Movie.new(rating: 'R')
kids_movie  = Movie.new(rating: 'PG')

evaluator.allowed? minor, :can_buy_the_ticket, scary_movie        # false
evaluator.allowed? not_a_minor, :can_buy_the_ticket, scary_movie  # true

evaluator.allowed? minor, :can_buy_the_ticket, kids_movie        # true
evaluator.allowed? not_a_minor, :can_buy_the_ticket, kids_movie  # true
```

Only one more special thing... what if we want to right a rule that prevents something?

```ruby
module DefaultLibraryRules
  def self.allowed user, book
    [:reserve_the_book]
  end
end

module FinesOwedRules
  def self.prevented user, _
    if user.owes_fines?
      [:reserve_the_book]
    else
      []
    end
  end
end

evaluator = Three.evaluator_for(DefaultLibraryRules, FinesOwedRules)

deadbeat            = User.new(fines: 3.0)
responsible_citizen = User.new(fines: 0)

evaluator.allowed? deadbeat, :reserve_the_book             # false
evaluator.allowed? responsible_citizen, :reserve_the_book  # true

```

The "prevented" method works just like "allowed," except that it will remove the permission from any other rule's "allowed" method.

The "prevented" method is the only only feature added with six. 

