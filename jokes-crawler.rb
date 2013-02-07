#!/usr/bin/env ruby

require "net/http"
require "uri"
require 'nokogiri'
require 'open-uri'
require 'optparse'

CONTRIBUTORS = %w(
  Brandon Brenda Kelly Steve Andrea Dylan David Scott
  Donna Cindy Jim Nat Jesse Clare Valerie Ray
  Carly Noah Janet Matt Gina Michael Billy Jane
  Alison Jake Amanda
)

class MessageParser
  attr_accessor :url, :max_characters

  def initialize(url, max_characters, max_messages)
    @url = url
    @max_characters = max_characters
    @max_messages = max_messages
  end

  def parse
    puts "Retrieving messages..."
    messages = []
    doc = Nokogiri::HTML(open(@url))
    doc.css("#tier_4 div.left_column div.middle a").each do |link|
      message_url = link['href']
      message = Nokogiri::HTML(open(message_url))
      message.css("div.arrow_area > div.content_wrap p").each do |ele|
        text = ele.content
        text.strip!
        messages << text unless text.length > @max_characters || text.length < 10
      end
      break if messages.length >= @max_messages
    end
    puts "#{messages.length} messages found."
    messages
  end

  def to_s
    "URL: #@url, max characters: #@max_characters"
  end
end

class SosMessageClient
  attr_accessor :sosmessage_url, :category_id, :post_url

  def initialize(sosmessage_url, category_id)
    @sosmessage_url = sosmessage_url
    @category_id = category_id
    @post_url = "#{@sosmessage_url}/v2/categories/#{@category_id}/message"
  end

  def postMessages(messages)
    puts "Posting #{messages.length} messages to #{@post_url} ..."
    uri = URI.parse(@post_url)
    messages_posted = 0
    messages.each do |message|
      response = Net::HTTP.post_form(uri, {"text" => message, "contributorName" => CONTRIBUTORS.sample})
      messages_posted += 1 if response.code.to_i == 200
    end
    puts "#{messages_posted.to_s} messages successfully posted."
  end

  def to_s
    "SosMessag API URL: #@post_url"
  end
end

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = 'Usage: jokes-crawler.rb [options]'

  options[:categoryid] = nil
  opts.on('-c', '--category-id CATEGORY_ID', 'The category id where to post the jokes') do |category|
    options[:categoryid] = category
  end

  options[:sosmessageurl] = 'http://localhost:3000'
  opts.on('-s', '--sosmessage-url URL', 'The SosMessage API url') do |s|
    options[:sosmessageurl] = s
  end

  options[:messagesurl] = nil
  opts.on('-u', '--messages-url URL', 'The jokes category url') do |u|
    options[:messagesurl] = u
  end

  options[:maxmessages] = 100
  opts.on( '-f', '--max-messages MAX', Integer, 'MAX messages to fetch') do |max_messages|
    options[:maxmessages] = max_messages
  end

  options[:maxcharacters] = 5000
  opts.on( '-m', '--max-characters MAX', Integer, 'MAX characters of the joke') do |max_characters|
    options[:maxcharacters] = max_characters
  end

  options[:dryrun] = false
  opts.on( '-n', '--dry-run', "Don't actually post the messages, only display them") do |dry_run|
    options[:dryrun] = dry_run
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

if options[:messagesurl]
  if options[:dryrun]
    messages = MessageParser.new(options[:messagesurl], options[:maxcharacters], options[:maxmessages]).parse
    messages.each do |message|
      puts message
      puts ""
      puts "=========="
      puts ""
    end
  elsif options[:categoryid]
    client = SosMessageClient.new(options[:sosmessageurl], options[:categoryid])
    messages = MessageParser.new(options[:messagesurl], options[:maxcharacters], options[:maxmessages]).parse
    client.postMessages(messages)
  end
else
  puts optparse
  exit
end
