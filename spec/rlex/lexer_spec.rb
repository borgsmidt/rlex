require 'spec_helper'
require 'rlex'
include Rlex

describe Lexer do
  before :each do
    @lexer = Lexer.new
  end

  describe "next_token" do
    it "should return EOF_TOKEN when the lexer has been assigned no input" do
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should return EOF_TOKEN when there is no more input" do
      @lexer.start ""
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should raise an error when remaining input is not matched by any rules" do
      @lexer.start "unmatched input"
      lambda {@lexer.next_token}.should raise_error RuntimeError
    end

    it "should return EOF_TOKEN when instructed to ignore everything" do
      @lexer.ignore /.*/
      @lexer.start "input to be ignored"
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should return recognized keywords and finish with EOF_TOKEN" do
      @lexer.ignore /\s+/
      @lexer.keyword :special
      @lexer.start " \t\nspecialspecial   special   "
      special = Token.new :special, "special"
      @lexer.next_token.should eq special
      @lexer.next_token.should eq special
      @lexer.next_token.should eq special
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should return tokens matched by regular rules and finish with EOF_TOKEN" do
      @lexer.ignore /\s+/
      @lexer.rule :word, /\w+/
      @lexer.start "sentence with four tokens"
      @lexer.next_token.should eq Token.new :word, "sentence"
      @lexer.next_token.should eq Token.new :word, "with"
      @lexer.next_token.should eq Token.new :word, "four"
      @lexer.next_token.should eq Token.new :word, "tokens"
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should return all types of tokens and finish with EOF_TOKEN" do
      @lexer.ignore /\s+/
      @lexer.keyword :if
      @lexer.keyword :lparen, "("
      @lexer.keyword :rparen, ")"
      @lexer.rule :word, /\w+/
      @lexer.start "ifu ( if ) ifu"
      @lexer.next_token.should eq Token.new :word, "ifu"
      @lexer.next_token.should eq Token.new :lparen, "("
      @lexer.next_token.should eq Token.new :if, "if"
      @lexer.next_token.should eq Token.new :rparen, ")"
      @lexer.next_token.should eq Token.new :word, "ifu"
      @lexer.next_token.should eq EOF_TOKEN
    end
  end
end
