#!/usr/bin/env ruby

require 'sinatra'
require 'open-uri'
require 'nokogiri'

get '/dilbert' do
  content_type 'text/xml'
  open('http://feeds.dilbert.com/DilbertDailyStrip?format=xml') do |response|
    xml_doc = Nokogiri::XML(response.read.to_s)

    xml_doc.xpath('/atom:feed/atom:entry', :atom => "http://www.w3.org/2005/Atom").each do |entry|
      url = entry.xpath('feedburner:origLink/text()').to_s
      img = open(url) do |response|
        html_doc = Nokogiri::HTML(response.read.to_s)
        html_doc.css('.img-comic')[0]
      end
      entry.xpath('atom:content', :atom => "http://www.w3.org/2005/Atom")[0].content = img.to_s
    end
    xml_doc.to_s
  end
end
