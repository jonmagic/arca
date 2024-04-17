# ActiveRecord Callback Analyzer

Arca is a callback analyzer for ActiveRecord models ideally suited for digging yourself out of callback hell. At best it will help you move towards a [more maintainable design](https://web.archive.org/web/20161016162603/http://adequate.io/culling-the-activerecord-lifecycle) and at worst it can be used in your test suite to give you feedback when callbacks change.

Arca helps you answer questions like:

* how spread out callbacks are for each model
* how many callbacks use conditionals (`:if`, `:unless`, and `:on`)
* how many possible permutations exist per callback type (`:commit`, `:create`, `:destroy`, `:find`, `:initialize`, `:rollback`, `:save`, `:touch`, `:update`, `:validation`) taking conditionals into consideration

The Arca library has two main components, the collector and the reporter. Include the collector module in ActiveRecord::Base before your models are loaded.

At GitHub, we test callbacks by whitelisting existing callbacks, and adding a lint test to ensure new callbacks are not added without review. The [examples](examples) folder is a good starting point.

## Requirements

![travis-ci build status](https://travis-ci.org/jonmagic/arca.svg)

Arca is tested against ActiveRecord 3.2 and 4.2 running on Ruby 1.9.3, 2.0.0, 2.1.0, and 2.2.0.

## Usage

Add the gem to your Gemfile and run `bundle`.

```
gem 'arca'
```

In your test helper (`test/test_helper.rb` for example) require the Arca library and include the `Arca::Collector` in `ActiveRecord::Base`.

```
require "active_record"
require "arca"

class ActiveRecord::Base
  include Arca::Collector
end

# load your app. It's important to setup before loading your models because Arca
# works by wrapping itself around the callback method definitions (before_save,
# after_save, etc) and then records how and where those methods are used.
```

In this example the `Annoucements` module is included in `Ticket` and defines it's own callback.


```ruby
class Ticket < ActiveRecord::Base
  include Announcements

  before_save :set_title, :set_body
  before_save :upcase_title, :if => :title_is_a_shout?

  def set_title
    self.title ||= "Ticket id #{SecureRandom.hex(2)}"
  end

  def set_body
    self.body ||= "Everything is broken."
  end

  def upcase_title
    self.title = title.upcase
  end

  def title_is_a_shout?
    self.title.split(" ").size == 1
  end
end
```

```ruby
module Announcements
  def self.included(base)
    base.class_eval do
      after_save :announce_save
    end
  end

  def announce_save
    puts "saved #{self.class.name.downcase}!"
  end
end
```

Use `Arca[Ticket].report` to analyze the callbacks for the `Ticket` class.

```ruby
> Arca[Ticket].report
{
                   :model_name => "Ticket",
              :model_file_path => "test/fixtures/ticket.rb",
              :callbacks_count => 4,
           :conditionals_count => 1,
          :lines_between_count => 6,
     :external_callbacks_count => 1,
       :external_targets_count => 0,
  :external_conditionals_count => 0,
      :calculated_permutations => 2
}
```

Try out `Arca[Ticket].analyzed_callbacks` to see where and how each callback works and the order they run in.

```ruby
> Arca[Ticket].analyzed_callbacks
{
  :before_save => [
    {
      :callback                       => :before_save,
      :callback_file_path             => "test/fixtures/ticket.rb",
      :callback_line_number           => 5,
      :external_callback              => false,
      :target                         => :set_title,
      :target_file_path               => "test/fixtures/ticket.rb",
      :target_line_number             => 8,
      :external_target                => false,
      :lines_to_target                => 3,
      :conditional                    => nil,
      :conditional_target             => nil,
      :conditional_target_file_path   => nil,
      :conditional_target_line_number => nil,
      :external_conditional_target    => nil,
      :lines_to_conditional_target    => nil
    },
    {
      :callback                       => :before_save,
      :callback_file_path             => "test/fixtures/ticket.rb",
      :callback_line_number           => 5,
      :external_callback              => false,
      :target                         => :set_body,
      :target_file_path               => "test/fixtures/ticket.rb",
      :target_line_number             => 12,
      :external_target                => false,
      :lines_to_target                => 7,
      :conditional                    => nil,
      :conditional_target             => nil,
      :conditional_target_file_path   => nil,
      :conditional_target_line_number => nil,
      :external_conditional_target    => nil,
      :lines_to_conditional_target    => nil
    },
    {
      :callback                       => :before_save,
      :callback_file_path             => "test/fixtures/ticket.rb",
      :callback_line_number           => 6,
      :external_callback              => false,
      :target                         => :upcase_title,
      :target_file_path               => "test/fixtures/ticket.rb",
      :target_line_number             => 16,
      :external_target                => false,
      :lines_to_target                => 10,
      :conditional                    => :if,
      :conditional_target             => :title_is_a_shout?,
      :conditional_target_file_path   => "test/fixtures/ticket.rb",
      :conditional_target_line_number => 20,
      :external_conditional_target    => false,
      :lines_to_conditional_target    => nil
    }
  ],
  :after_save  => [
    {
      :callback                       => :after_save,
      :callback_file_path             => "test/fixtures/announcements.rb",
      :callback_line_number           => 4,
      :external_callback              => true,
      :target                         => :announce_save,
      :target_file_path               => "test/fixtures/announcements.rb",
      :target_line_number             => 8,
      :external_target                => false,
      :lines_to_target                => 4,
      :conditional                    => nil,
      :conditional_target             => nil,
      :conditional_target_file_path   => nil,
      :conditional_target_line_number => nil,
      :external_conditional_target    => nil,
      :lines_to_conditional_target    => nil
    }
  ]
}
```

I'm working [on a project](https://help.github.com/enterprise/2.3/admin/guides/migrations/) at [GitHub](https://github.com) that feels pain when callback behavior changes so I decided to build this tool to help us manage change better and hopefully in the long run move away from ActiveRecord callbacks for most things.

For the first iteration I am hoping to use this tool in a set of model lint tests that break when callback behavior changes.

```ruby
  def assert_equal(expected, actual)
    super(expected, actual, ARCA_FAILURE_MESSAGE)
  end

  def test_foo
    report = Arca[Foo].report
    expected = {
      :model_name                  => "Foo",
      :model_file_path             => "app/models/foo.rb",
      :callbacks_count             => 30,
      :conditionals_count          => 3,
      :lines_between_count         => 1026,
      :external_callbacks_count    => 12,
      :external_targets_count      => 3,
      :external_conditionals_count => 2,
      :calculated_permutations     => 11
    }

    assert_equal expected, report.to_hash
  end
  ```

  When change happens and that test fails it outputs a helpful error message.

```
---------------------------------------------
Please /cc @github/migration on the PR if you
have to update this test to make it pass.
---------------------------------------------
```

## Contributors

- [@jonmagic](https://github.com/jonmagic)
- [@jch](https://github.com/jch)
- [@bensheldon](https://github.com/bensheldon)
- [@jasonkim](https://github.com/jasonkim)

## License

The MIT License (MIT)

Copyright (c) 2015 Jonathan Hoyt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
