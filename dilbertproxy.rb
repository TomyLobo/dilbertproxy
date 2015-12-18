#!/usr/bin/env ruby

require 'sinatra'
require 'open-uri'
require 'nokogiri'

get '/dilbert' do
  xml = open('http://feeds.dilbert.com/DilbertDailyStrip?format=xml') do |response|
    response.read.to_s
  end

  xml_doc = Nokogiri::XML(xml)

  xml_doc.xpath('/atom:feed/atom:entry', :atom => "http://www.w3.org/2005/Atom").each do |entry|
    url = entry.xpath('feedburner:origLink/text()').to_s
    html = open(url) do |response|
      response.read.to_s
    end

    html_doc = Nokogiri::HTML(html)

    img = html_doc.css('.img-comic')[0]
    entry.xpath('atom:content', :atom => "http://www.w3.org/2005/Atom")[0].content = img.to_s
  end

  content_type 'text/xml'
  xml_doc.to_s
end
