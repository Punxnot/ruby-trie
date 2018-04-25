require 'sinatra'
require 'mongoid'

# DB Setup
Mongoid.load! "mongoid.config"

# Models

class Trie
  include Mongoid::Document
  # field :root, type: String
  attr_accessor :root

  def initialize()
    @root = {}
  end

  def add(word,subtree=@root)
    if word.size == 0
      subtree[:terminal] = true
    else
      first_char = word[0]
      rest = word[1..-1]
      subtree[first_char] ||= {}
      add(rest, subtree[first_char])
    end
  end

  def include?(word)
    subtree = walk(word)
    if subtree and subtree[:terminal]
      return true
    else
      return false
    end
  end

  def find(prefix)
    subtree = walk(prefix)
    return [] unless subtree
    return words(subtree, prefix)
  end

  def words(subtree = @root, prefix="", words=[] )
    subtree.each do |key, next_subtree|
      if key == :terminal
        words << prefix
      else
        words(next_subtree, prefix + key.chr, words)
      end
    end
    return words
  end

  private

  def walk(word)
    subtree = @root
    word.each_char do |char|
      subtree = subtree[char]
      return false if subtree.nil?
    end
    return subtree
  end
end

my_trie = Trie.new

get '/' do
  my_trie.words().to_json
end

get '/add/:word' do |word|
  my_trie.add(word.to_s)
  my_trie.words().to_json
end

get '/words/:prefix' do
  my_trie.find(params[:prefix].to_s).to_json
end

get '/trie' do
  my_trie.root.to_json
end
