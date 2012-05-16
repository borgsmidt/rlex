module Rlex
  # Simple class to represent tokens matched from the input.
  #
  # @author Rasmus Borgsmidt <rasmus@borgsmidt.dk>
  #
  # @attr_reader [Symbol] type Type of the token, such as the name of
  #   the rule used to match it
  # @attr_reader [String] value Text matched from the input
  # @attr_reader [Integer] line Line number of the matched text
  # @attr_reader [Integer] col Column position of the matched text
  #
  Token = Struct.new :type, :value, :line, :col

  # Special token used when the lexer has reached the end of the
  # specified input.
  #
  EOF_TOKEN = Token.new :eof, "", -1, -1
end
