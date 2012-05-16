require 'strscan'
require 'rlex/token'

module Rlex
  # Implements a simple lexer using a <tt>StringScanner</tt>.
  #
  # The lexer was written for use with Racc, a Ruby variant of
  # Yacc. But there is no code dependency on that project so the
  # lexer may also be used on its own or with other packages.
  #
  # * Ignored input takes precedence over rules and keywords, so if
  #   a prefix is matched by an ignore pattern, it's ignored even if
  #   it's also a keyword or matched by a rule
  # * The lexer is greedy, so if a prefix is matched by multiple
  #   rules or keywords, the lexer chooses the option consuming the
  #   most input
  #
  # @author Rasmus Borgsmidt <rasmus@borgsmidt.dk>
  #
  # @example Basic usage
  #   # Define behavior
  #   lexer = Lexer.new
  #   lexer.ignore /\s+/                   # ignore whitespace
  #   lexer.rule :word, /\w+/              # consider any text a 'word'
  #   lexer.keyword :if                    # treat 'if' as a special keyword
  #   lexer.keyword :lparen, "("           # any fixed input such as parentheses
  #   lexer.keyword :rparen, ")"           #   may be defined as keywords
  #
  #   # Initialize with input
  #   lexer.start "if ( foo ) bar"         # initialize the lexer with a string
  #
  #   # Iterate through tokens
  #   lexer.next_token # => Token (type = :if,     value = 'if')
  #   lexer.next_token # => Token (type = :lparen, value = '(')
  #   lexer.next_token # => Token (type = :word,   value = 'foo')
  #   lexer.next_token # => Token (type = :rparen, value = ')')
  #   lexer.next_token # => Token (type = :word,   value = 'bar')
  #   lexer.next_token # => EOF_TOKEN
  #
  class Lexer
    # Initializes an empty Lexer.
    #
    def initialize
      @ignored = []
      @rules = []
      @keywords = {}
    end

    # Instructs the lexer to ignore input matched by the specified
    # pattern. If appropriate, call this multiple times to ignore
    # several patterns.
    #
    # @note Ignored input takes precedence over rules and keywords,
    #   so if a prefix is matched by an ignore pattern, it's ignored
    #   even if it's also a keyword or matched by a rule
    #
    # @param [Regexp] pattern Pattern of input to ignore
    #
    # @return [Regexp] The specified pattern
    #
    def ignore(pattern)
      @ignored << pattern
      return pattern
    end

    # Defines a rule to match the specified pattern.
    #
    # @note Use keywords for efficiency instead of rules whenever
    #   the matched input is static
    #
    # @param [Symbol, #to_sym] name Unique name of rule
    # @param [Regexp] pattern Pattern of input to match
    #
    # @raise [ArgumentError] If the specified name is already
    #   used by other rules or keywords
    #
    # @return [Symbol] The name of the rule
    #
    def rule(name, pattern)
      # @todo Validate the rule name
      @rules << (Rule.new name.to_sym, pattern)
      return name.to_sym
    end

    # Defines a static sequence of input as a keyword.
    #
    # @note Use keywords for efficiency instead of rules whenever
    #   the matched input is static
    #
    # @param [optional, Symbol, #to_sym] name Unique name of the
    #   keyword. If this argument is not given, the keyword is used
    #   to name itself
    # @param [String, #to_s] kword Sequence of input to match as a
    #   keyword
    #
    # @raise [ArgumentError] If the specified name is already
    #   used by other rules or keywords
    #
    # @return [Symbol] The name of the keyword
    #
    def keyword(name = nil, kword)
      # @todo Validate the keyword name
      kword_str = kword.to_s
      name = kword.to_sym if name == nil
      pattern = Regexp.new(Regexp.escape kword_str)
      rule name, pattern
      @keywords[kword_str] = Token.new name.to_sym, kword_str
      return name.to_sym
    end

    # Initializes the lexer with new input. 
    #
    # @note This resets the lexer with a new StringScanner so any
    #   state information related to previous input is lost
    #
    # @param [String] input Input to scan for tokens
    #
    # @return [String] The specified input
    #
    def start(input)
      @line = 1
      @col = 0
      @scanner = StringScanner.new input
      return input
    end

    # Returns the next token matched from the remaining input. If no
    # input is left, or the lexer has not been initialized,
    # <tt>EOF_TOKEN</tt> is returned.
    #
    # @raise [RuntimeError] If there is any unmatched input
    #
    # @return [Token] Next token or <tt>EOF_TOKEN</tt>
    #
    def next_token
      return EOF_TOKEN if @scanner.nil? or @scanner.empty?
      return next_token if ignore_prefix?
      rule = greediest_rule
      if rule
        prefix = fetch_prefix_and_update_pos(rule.pattern)
        keyword = @keywords[prefix]
        type = keyword ? keyword.type : rule.name
        token = keyword ? keyword.value : prefix
        return Token.new(type, token, @line, @col - token.size)
      end
      raise "unexpected input <#{@scanner.peek(5)}>"
    end

    private

    # @private
    Rule = Struct.new :name, :pattern

    # @private
    def ignore_prefix?
      @ignored.each do |pattern|
        prefix = fetch_prefix_and_update_pos(pattern)
        return true if prefix
      end
      return false
    end

    # @private
    def greediest_rule
      r = nil
      len = 0
      @rules.each do |rule|
        prefix = @scanner.check(rule.pattern)
        if prefix and prefix.length > len
          r = rule
          len = prefix.length
        end
      end
      return r
    end

    # @private
    def fetch_prefix_and_update_pos(pattern)
      prefix = @scanner.scan(pattern)
      return nil if not prefix
      parts = prefix.split("\n", -1) # arg -1 allows empty lines
      if parts.count == 1
        # Staying on the same line
        @col += prefix.length
      else
        # On a new line
        @line += parts.count - 1
        @col = parts.last.length
      end
      return prefix
    end
  end
end
