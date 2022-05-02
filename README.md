# Semgrep::Changes

[![Gem Version](https://img.shields.io/gem/v/semgrep-changes)](https://rubygems.org/gems/semgrep-changes)
[![Build Status](https://github.com/fcsonline/semgrep-changes/actions/workflows/ci.yml/badge.svg)](https://github.com/fcsonline/semgrep-changes/actions/workflows/ci.yml)

`semgrep-changes` shows only the offenses you introduced since the fork point
of your git branch. Will not complain about existing offenses in your main
branch.

This is useful for CI checks for your pull requests but it could be useful too
for you daily work, to know new offenses created by you.

Internally `semgrep-changes` reads the `json` output from `semgrep` and a `git
diff` and does the intersection of line numbers to know the new offenses you
are introducing to you main branch.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'semgrep-changes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install semgrep-changes

## Usage

    $ bundle exec semgrep-changes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fcsonline/semgrep-changes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Semgrep::Changes project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fcsonline/semgrep-changes/blob/master/CODE_OF_CONDUCT.md).
