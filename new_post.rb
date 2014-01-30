#!/usr/bin/env ruby

require 'date'
require 'pathname'

title = ARGV[0]

slug = title.gsub(/\s/, '-').gsub(/[^-_\w\d]/, '')

now = DateTime.now
dirname = sprintf("_posts/%d", now.year)
filename = sprintf("%02d-%02d-%02d-%s.md", now.year, now.month, now.day, slug)

path = Pathname.new(dirname)
path.mkpath
path += filename
File.open(path, "w") do |f|
  f << "---
title: \"#{title}\"
tags: []
layout: post
comments: true
---

"
end

puts "Creating new post: #{path}"
