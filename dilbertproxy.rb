#!/usr/bin/env ruby

require 'sinatra'
require 'open-uri'
require 'nokogiri'

get '/dilbert' do
  xml = open('http://feeds.dilbert.com/DilbertDailyStrip?format=xml').read.to_s

  xml_doc = Nokogiri::XML(xml)

  xml_doc.xpath('/xmlns:feed/xmlns:entry').each do |entry|
    url = entry.xpath('feedburner:origLink/text()')[0].content
    html = open(url).read.to_s

    html_doc = Nokogiri::HTML(html)

    img = html_doc.css('.img-comic')[0]
    entry.xpath('xmlns:content')[0].content = img.to_s

    updated_node = entry.xpath('xmlns:updated')[0]
    updated_node.content = updated_node.content.gsub('23:59:59', '00:00:00')
  end

  content_type 'text/xml'
  xml_doc.to_s
end
