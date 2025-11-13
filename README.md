# Validates Nested Uniqueness

[![Ruby](https://github.com/mamantoha/validates_nested_uniqueness/actions/workflows/ruby.yml/badge.svg)](https://github.com/mamantoha/validates_nested_uniqueness/actions/workflows/ruby.yml)
[![GitHub release](https://img.shields.io/github/release/mamantoha/validates_nested_uniqueness.svg)](https://github.com/mamantoha/validates_nested_uniqueness/releases)
[![Gem Version](https://badge.fury.io/rb/rails_validates_nested_uniqueness.svg)](https://badge.fury.io/rb/rails_validates_nested_uniqueness)
[![License](https://img.shields.io/github/license/mamantoha/validates_nested_uniqueness.svg)](https://github.com/mamantoha/validates_nested_uniqueness/blob/main/LICENSE)

Validates whether associations are uniqueness when using `accepts_nested_attributes_for`.

Solves the original Rails issue [#20676](https://github.com/rails/rails/issues/20676).

This issue is very annoying and still open after years. And probably this will never be fixed.

This code is based on solutions proposed in the thread. Thanks everyone ❤️.

## Installation

`rails_validates_nested_uniqueness` works with Rails 7.2 onwards.

Add this to your Rails project's `Gemfile`:

```ruby
gem 'rails_validates_nested_uniqueness'
```

Or install directly:

```bash
gem install rails_validates_nested_uniqueness
```

## Usage

Making sure that only one `city` of the `country` can be named "NY".

```ruby
class City < ActiveRecord::Base
  belongs_to :country
end

class Country < ActiveRecord::Base
  has_many :cities, dependent: :destroy
  accepts_nested_attributes_for :cities, allow_destroy: true

  validates :cities, nested_uniqueness: {
    attribute: :name,
    scope: [:country_id],
    case_sensitive: false
  }
end

country = Country.new(name: 'US', cities: [City.new(name: 'NY'), City.new(name: 'NY')])
country.save
# => false

country.errors
# => #<ActiveModel::Errors [#<ActiveModel::NestedError attribute=cities.name, type=taken, options={:value=>"NY", :message=>nil}>]>

country.errors.messages
# => {"cities.name"=>["has already been taken"]}
```

## Advanced Usage

### Custom Comparison Logic

For more complex validation scenarios, you can provide custom comparison logic:

```ruby
validates :cities, nested_uniqueness: {
  attribute: :name,
  scope: [:country_id],
  comparison: ->(value) { value.to_s.strip.downcase }
}
```

This is useful when you need to normalize values before comparison (e.g., trimming whitespace, handling special characters, etc.).

Configuration options:

- `:attribute` - (Required) Specify the attribute name of associated model to validate.
- `:scope` - One or more columns by which to limit the scope of the uniqueness constraint.
- `:case_sensitive` - Looks for an exact match. Ignored by non-text columns (`true` by default).
- `:message` - A custom error message (default is: "has already been taken").
- `:error_key` - A custom error key to use (default is: `:taken`).
- `:comparison` - A callable object (Proc/lambda) for custom value comparison logic.

## Sponsorship

This library is sponsored by [Faria Education Group](https://github.com/eduvo), where it was originally developed and utilized in a production project. It has been extracted and refined for open-source use.

## Contributing

1. Fork it (<https://github.com/mamantoha/validates_nested_uniqueness/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer

## License

Copyright: 2021-2025 Anton Maminov (anton.maminov@gmail.com)

This library is distributed under the MIT license. Please see the LICENSE file.
