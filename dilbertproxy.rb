#!/usr/bin/env ruby

require 'sinatra'
require 'open-uri'
require 'nokogiri'

get '/dilbert' do
  xml = open('http://feeds.dilbert.com/DilbertDailyStrip?format=xml') do |response|
    response.read.to_s
  end

  xml_doc = Nokogiri::XML(xml)
  xml_doc.root.add_namespace_definition('atom', "http://www.w3.org/2005/Atom")

  xml_doc.xpath('/atom:feed/atom:entry').each do |entry|
    url = entry.xpath('feedburner:origLink/text()')[0].content
    html = open(url) do |response|
      response.read.to_s
    end

    html_doc = Nokogiri::HTML(html)

    img = html_doc.css('.img-comic')[0]
    entry.xpath('atom:content')[0].content = img.to_s

    updated_node = entry.xpath('atom:updated')[0]
    updated_node.content = updated_node.content.gsub('23:59:59', '00:00:00')
  end

  content_type 'text/xml'
  xml_doc.to_s
end
