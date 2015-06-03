require 'fileutils'

# Read Tags into array
tags = []
taglist_path = File.expand_path("../../_site/archive/taglist.txt", __FILE__)
File.open(taglist_path, 'r') do |f1|
    while tag = f1.gets
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
        File.open(tagpage_path, 'w') do |f2|
          f2.puts "---"
          f2.puts "layout: archive"
          f2.puts "title: #{tag}"
          f2.puts "tag: #{tag}"
          f2.puts "permalink: tag/#{tagpath}/"
          f2.puts "---"
        end
        puts "created #{tag.downcase}.md"
    end
end




# Read Dates into array
dates = []
datelist_path = File.expand_path("../../_site/archive/datelist.txt", __FILE__)
File.open(datelist_path, 'r') do |f1|
    while date = f1.gets
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
        File.open(yearpage_path, 'w') do |f2|
          f2.puts "---"
          f2.puts "layout: archive"
          f2.puts "title: #{year}"
          f2.puts "year: '#{year}'"
          f2.puts "permalink: #{year}/"
          f2.puts "---"
        end
        puts "created #{tag.downcase}.md"
    end

    month = date[1]
    monthpage_path = File.expand_path("../#{year}/#{month}/index.md", __FILE__)
    unless File.exists?(monthpage_path)
        FileUtils.mkdir_p(File.dirname(monthpage_path))
        File.open(monthpage_path, 'w') do |f3|
          f3.puts "---"
          f3.puts "layout: archive"
          f3.puts "title: #{month_names[Integer(month)]} #{year}"
          f3.puts "year: '#{year}'"
          f3.puts "month: '#{month}'"
          f3.puts "permalink: #{year}/#{month}/"
          f3.puts "---"
        end
    end
end
