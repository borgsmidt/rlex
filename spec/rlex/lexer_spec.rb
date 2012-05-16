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
      @lexer.next_token.should eq Token.new(:special, "special", 2, 0)
      @lexer.next_token.should eq Token.new(:special, "special", 2, 7)
      @lexer.next_token.should eq Token.new(:special, "special", 2, 17)
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should return tokens matched by regular rules and finish with EOF_TOKEN" do
      @lexer.ignore /\s+/
      @lexer.rule :word, /\w+/
      @lexer.start "sentence with four tokens"
      @lexer.next_token.should eq Token.new(:word, "sentence", 1, 0)
      @lexer.next_token.should eq Token.new(:word, "with", 1, 9)
      @lexer.next_token.should eq Token.new(:word, "four", 1, 14)
      @lexer.next_token.should eq Token.new(:word, "tokens", 1, 19)
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should return all types of tokens and finish with EOF_TOKEN" do
      @lexer.ignore /\s+/
      @lexer.keyword :if
      @lexer.keyword :lparen, "("
      @lexer.keyword :rparen, ")"
      @lexer.rule :word, /\w+/
      @lexer.start "ifu ( if ) ifu"
      @lexer.next_token.should eq Token.new(:word, "ifu", 1, 0)
      @lexer.next_token.should eq Token.new(:lparen, "(", 1, 4)
      @lexer.next_token.should eq Token.new(:if, "if", 1, 6)
      @lexer.next_token.should eq Token.new(:rparen, ")", 1, 9)
      @lexer.next_token.should eq Token.new(:word, "ifu", 1, 11)
      @lexer.next_token.should eq EOF_TOKEN
    end

    it "should recognize keywords even if declared after rules which also match" do
      @lexer.ignore /\s+/
      @lexer.rule :word, /\w+/
      @lexer.keyword :keyword
      @lexer.start "word keyword keywordmore"
      @lexer.next_token.should eq Token.new(:word, "word", 1, 0)
      @lexer.next_token.should eq Token.new(:keyword, "keyword", 1, 5)
      @lexer.next_token.should eq Token.new(:word, "keywordmore", 1, 13)
      @lexer.next_token.should eq EOF_TOKEN
    end
  end
end
