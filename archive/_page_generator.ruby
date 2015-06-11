require 'fileutils'

# Read Tags into array
tags = []
taglist_path = File.expand_path("../../_site/archive/taglist.txt", __FILE__)
File.open(taglist_path, 'r') do |f|
    while tag = f.gets
        tag = tag.strip
        unless tag == "" || tag == "\n"
            tags += [tag]
        end
    end
end
puts "found following tags: #{tags}"

# Create .md files for each tag
for tag in tags
    tagpath = tag.include?(' ') ? tag.downcase.gsub!(' ','-') : tag.downcase
    tagpage_path = File.expand_path("../tags/#{tagpath}.md", __FILE__)
    unless File.exists?(tagpage_path)
        FileUtils.mkdir_p(File.dirname(tagpage_path))
        File.open(tagpage_path, 'w') do |f|
          f.puts "---"
          f.puts "layout: archive"
          f.puts "title: #{tag}"
          f.puts "tag: #{tag}"
          f.puts "permalink: tags/#{tagpath}/"
          f.puts "redirect_from: archive/tags/#{tagpath}/"
          f.puts "---"
        end
        puts "created #{tag.downcase}.md"
    end
end




# Read Dates into array
dates = []
datelist_path = File.expand_path("../../_site/archive/datelist.txt", __FILE__)
File.open(datelist_path, 'r') do |f|
    while date = f.gets
        date = date.strip
        unless date == "" || date == "\n"
            dates += [[date[0..3], date[5..6], date[8..9]]]
        end
    end
end
puts "found following dates: #{dates}"

# Create .md files for each year, month, and day
month_names = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "Oktober", "November", "December"]
for date in dates
    year = date[0]
    yearpage_path = File.expand_path("../#{year}/index.md", __FILE__)
    unless File.exists?(yearpage_path)
        FileUtils.mkdir_p(File.dirname(yearpage_path))
        File.open(yearpage_path, 'w') do |f|
          f.puts "---"
          f.puts "layout: archive"
          f.puts "title: #{year}"
          f.puts "year: '#{year}'"
          f.puts "permalink: #{year}/"
          f.puts "redirect_from: archive/#{year}/"
          f.puts "---"
        end
        puts "created #{tag.downcase}.md"
    end

    month = date[1]
    monthpage_path = File.expand_path("../#{year}/#{month}/index.md", __FILE__)
    unless File.exists?(monthpage_path)
        FileUtils.mkdir_p(File.dirname(monthpage_path))
        File.open(monthpage_path, 'w') do |f|
          f.puts "---"
          f.puts "layout: archive"
          f.puts "title: #{month_names[Integer(month)]} #{year}"
          f.puts "year: '#{year}'"
          f.puts "month: '#{month}'"
          f.puts "permalink: #{year}/#{month}/"
          f.puts "redirect_from: archive/#{year}/#{month}/"
          f.puts "---"
        end
    end
end
