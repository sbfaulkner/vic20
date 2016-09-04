# Vic20

A VIC-20 emulator built in ruby.

## TODO

This is very much a work in progress.

1. <del>Implementing the 6502 instruction set.</del>
2. <del>Refactoring to eliminate duplicate load and store operations, and clean up reading of operands.</del>
3. Consider switching to array indexing of flag bits.
4. <del>Reference instance variables directly instead of using accessors (performance).</del>
5. DRY up SBC implementation since it's just ADC with ones-complement of (2nd) operand.
6. specs for ADC and SBC not complete/correct for carry & overflow.
7. MemoryMappedArray implementation does not check bounds - SEGV may result if abused.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vic20'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vic20

## Usage

To start the message:

```
$ bin/run
```

To create the machine and enter an interactive console:

```
$ bin/console
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/vic20. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
