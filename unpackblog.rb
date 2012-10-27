# unpack old blog dump

require 'yaml'
require 'RedCloth'
require 'iconv'
require 'cgi'

table = YAML.load_file("wp_p3ba63_posts.yml")

table.each do |row|
	if row["post_status"] == "publish" then
		title = row["post_title"]
		content = row["post_content"]
		date = row["post_date"]
		#puts "#{title}..."
		#puts content
		
		begin
			title = Iconv.conv("CP1252", "UTF8", title)
		rescue
		end
		title = CGI.unescapeHTML(title)
		
		begin
			content = Iconv.conv("CP1252", "UTF8", content)
		rescue
		end
		
		if /(\d+)-(\d+)-(\d+)/ =~ date then
			dateslug = "#{$1}-#{$2}-#{$3}"
			year = $1
		else
			die "Unknown date format: #{date}"
		end
		
		slug = title.gsub("/",":").gsub(" ",'-')
		
		html = RedCloth.new(content).to_html
		
		dirname = "_posts/#{year}"
		begin
			Dir.mkdir(dirname)
		rescue Errno::EEXIST
		end
		
		filename = "#{dirname}/#{dateslug}-#{slug}.textile"
		File.open(filename, "w") do |io|
			io.write(
"---
layout: post
title: \"#{title}\"
---
")
		  	io.write(content)
	  end
	end
end