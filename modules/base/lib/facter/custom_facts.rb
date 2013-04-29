#!/usr/bin/ruby
#
require 'rubygems'
require 'crack'
filePath =  "#{ENV['HOME']}" << "/.rightscale/server.xml"
if File.exist?("#{filePath}")
   xml = Crack::XML.parse(File.read("#{filePath}"))
   xml["ec2_instance"]["parameters"].each { |parameter|
        p_name = parameter["name"]
        p_value = parameter["value"]
        puts "#{p_name}=#{p_value.split(":",2).last}"
  }
end