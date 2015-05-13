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
puts "found following tags: #{tags} \n\n"

# Create .md files for each tag
for tag in tags
    tagpage_path = File.expand_path("../#{tag.downcase}.md", __FILE__)
    unless File.exists?(tagpage_path)
        File.open(tagpage_path, 'w') do |f2|
          f2.puts "---"
          f2.puts "layout: archive_tag"
          f2.puts "title: #{tag}"
          f2.puts "permalink: tag/#{tag.downcase}/"
          f2.puts "---"
        end
        puts "created #{tag.downcase}.md"
    else
        puts "found #{tag.downcase}.md, did nothing"
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
puts "\nfound following dates: #{dates}\n\n"

# Create .md files for each year, month, and day
month_names = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "Oktober", "November", "December"]
for date in dates
    year = date[0]
    month = date[1]

    yearpage_path = File.expand_path("../#{year}/index.md", __FILE__)
    monthpage_path = File.expand_path("../#{year}/month/index.md", __FILE__)

    File.open(yearpage_path, 'w') do |f2|
      f2.puts "---"
      f2.puts "layout: archive_year"
      f2.puts "title: #{year}"
      f2.puts "date: '#{year}'"
      f2.puts "permalink: #{year}/"
      f2.puts "---"
    end
    puts "created #{tag.downcase}.md"

    File.open(monthpage_path, 'w') do |f3|
      f3.puts "---"
      f3.puts "layout: archive_month"
      f3.puts "title: #{month_names[Integer(month)]} #{year}"
      f3.puts "date: '#{year}-#{month}'"
      f3.puts "permalink: #{year}/#{month}/"
      f3.puts "---"
    end
end
