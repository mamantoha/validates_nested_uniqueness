# Validates Nested Uniqueness

[![Ruby](https://github.com/mamantoha/validates_nested_uniqueness/actions/workflows/ruby.yml/badge.svg)](https://github.com/mamantoha/validates_nested_uniqueness/actions/workflows/ruby.yml)

This gem adds the capability of validating nested uniqueness to ActiveRecord.

<https://github.com/rails/rails/issues/20676>

## Installation

`validates_nested_uniqueness` works with Rails 4.1 onwards.

Add this to your `Gemfile`:

```ruby
gem "validates_nested_uniqueness"
```

Or install it yourself:

```console
gem install validates_nested_uniqueness
```

## Usage

```ruby
class City < ActiveRecord::Base
  belongs_to :country
end

class Country < ActiveRecord::Base
  has_many :cities, dependent: :destroy
  accepts_nested_attributes_for :cities, allow_destroy: true

  validates :cities, nested_uniqueness: {
    watch: :name,
    scope: [:country_id],
    case_sensitive: false
  }
end

country = Country.new(name: 'US', cities: [City.new(name: 'NY'), City.new(name: 'NY')])
country.save
# => false
```

## Contributing

1. Fork it (<https://github.com/mamantoha/validates_nested_uniqueness/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer

## License

Copyright: 2021 Anton Maminov (anton.maminov@gmail.com)

This library is distributed under the MIT license. Please see the LICENSE file.
