# Rlex

Provides a simple lexer based on the <tt>StringScanner</tt> class.

The lexer was written for use with Racc, a Ruby variant of
Yacc. But there is no code dependency on that project so the
lexer may also be used on its own or with other packages.

* Ignored input takes precedence over rules and keywords, so if
  a prefix is matched by an ignore pattern, it's ignored even if
  it's also a keyword or matched by a rule
* The lexer is greedy, so if a prefix is matched by multiple
  rules or keywords, the lexer chooses the option consuming the
  most input

## Documentation

Find out more about this project on [GitHub][gh_rlex],
[RubyGems][rg_rlex] and [RubyDoc][rd_rlex].

[gh_rlex]: https://github.com/borgsmidt/rlex
[rg_rlex]: http://rubygems.org/gems/rlex
[rd_rlex]: http://rubydoc.info/gems/rlex

## Installation

Install the gem using:

    $ gem install rlex
 
Alternatively, add this line to your application's Gemfile:

    gem 'rlex'

Then execute:

    $ bundle

## Usage

```ruby
# Define behavior
lexer = Lexer.new
lexer.ignore /\s+/                   # ignore whitespace
lexer.rule :word, /\w+/              # consider any text a 'word'
lexer.keyword :if                    # treat 'if' as a special keyword
lexer.keyword :lparen, "("           # any fixed input such as parentheses
lexer.keyword :rparen, ")"           #   may be defined as keywords

# Initialize with input
lexer.start "if ( foo ) bar"         # initialize the lexer with a string

# Iterate through tokens
lexer.next_token # => Token (type = :if,     value = 'if' )
lexer.next_token # => Token (type = :lparen, value = '('  )
lexer.next_token # => Token (type = :word,   value = 'foo')
lexer.next_token # => Token (type = :rparen, value = ')'  )
lexer.next_token # => Token (type = :word,   value = 'bar')
lexer.next_token # => EOF_TOKEN
```

## Contributing

1. Fork it on [GitHub][gh_rlex]
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Written by Rasmus Borgsmidt &lt;<rasmus@borgsmidt.dk>&gt;

Released under the MIT license: www.opensource.org/licenses/MIT
