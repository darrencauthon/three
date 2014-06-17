## Three - is a super-ultra simple authorization gem for ruby! 

[![Build Status](https://travis-ci.org/darrencauthon/three.png?branch=master)](https://travis-ci.org/darrencauthon/three)
[![Code Climate](https://codeclimate.com/github/darrencauthon/three.png)](https://codeclimate.com/github/darrencauthon/three)
[![Coverage Status](https://coveralls.io/repos/darrencauthon/three/badge.png)](https://coveralls.io/r/darrencauthon/three)

This gem started as a minor fork of [six](https://github.com/randx/six), a neat authorization gem that is also very simple to use.  I forked it for the following reasons:

1. I have concerns about how six holds state, allowing rules to be turned on-and-off.
1. six does not allow rules to be built based on relationships between objects.
1. six did not respond to my puller request to add the optional checking of relationships between objects.
1. I thought six could be even more simple.
1. Fun.

Though this started as a fork of six, three is a full rewrite.

### Installation

```ruby
  gem install three
```


### QuickStart

3 steps:

**Step 1:** Create an object with an "allowed" method. 

This method will receive one argument, the subject for which the rules are checked.  It will return an array of symbols, each of which will stand for a permission.

Here is an example of a method to see what permissions an admin will have.  The method will check the admin's roles and return the proper permissions as an array.

```ruby
class AdminRules
      
  def allowed admin
    rules = []
    rules << :can_edit_users if admin.is_a_super_admin?
    rules << :can_edit_documents if admin.is_a_librarian?
    rules
  end
      
end
```
    
Optionally, this method can accept two arguments.  The first argument is the subject, and the second argument is a target.  This method can be useful for determining permissions the subject has with regards to a relationship with another object.

```ruby
class ViewingRights
      
  def allowed viewer, movie
    return [] if movie.rated_r? and viewer.minor?
    [:can_watch]
  end
      
end
```
    
**Step 2:** Create a judge to enforce the rules

```ruby
  rules = [AdminRules.new, ViewingRights.new]
  
  judge = Three.judge_enforcing rules
```

**Step 3:** Now you can use the judge to determine the abilities of the objects in question.

```ruby

judge.allowed?(super_admin, :can_edit_users) # true

judge.allowed?(librarian, :can_edit_users)     # false
judge.allowed?(librarian, :can_edit_documents) # true

judge.allowed?(toddler, :can_watch, night_of_the_living_dead) # false
judge.allowed?(toddler, :can_watch, thomas_the_train)         # true
 
```
