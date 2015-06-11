MONTH_NAMES = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "Oktober", "November", "December"]

def write_file(path, link, title, options={})
    unless File.exists?(path)
        File.open(path, 'w') do |f|
            f.puts "---"
            f.puts "layout: archive"
            f.puts "permalink: #{link}"
            f.puts "redirect_from: archive/#{link}"
            f.puts "title: '#{title}'"
            options.each do |k, v|
                f.puts "#{k}: #{v}"
            end
            f.puts "---"
        end
        puts "created archive page for #{title}"
    end
end


# Create containing folders
tags_folder_path = File.expand_path("../tags/", __FILE__)
Dir.mkdir(tags_folder_path) unless File.exists?(tags_folder_path)
yearmonth_folder_path = File.expand_path("../months/", __FILE__)
Dir.mkdir(yearmonth_folder_path) unless File.exists?(yearmonth_folder_path)


# Read Tags into array
tags = []
taglist_path = File.expand_path("../../_site/archive/taglist.txt", __FILE__)
File.open(taglist_path, 'r') do |f|
    while tag = f.gets
        tag = tag.strip
        tags += [tag] unless tag == "" || tag == "\n"
    end
end
# Read Dates into array
dates = []
datelist_path = File.expand_path("../../_site/archive/datelist.txt", __FILE__)
File.open(datelist_path, 'r') do |f|
    while date = f.gets
        date = date.strip
        dates += [[date[0..3], date[5..6], date[8..9]]] unless date == "" || date == "\n"
    end
end


# Create template files for each tag
for tag in tags
    tagpath = tag.include?(' ') ? tag.downcase.gsub!(' ','-') : tag.downcase
    tagpage_path = tags_folder_path + "/#{tagpath}.md"
    write_file(tagpage_path, "tags/#{tagpath}/", tag, {tag: "'#{tag}'"})
end
# Create template files for each year and month
for date in dates
    year = date[0]
    yearpage_path = yearmonth_folder_path + "/#{year}.md"
    write_file(yearpage_path, "#{year}/", year, {year:"#{year}"})

    month = date[1]
    monthpage_path = yearmonth_folder_path + "/#{year}-#{month}.md"
    month_name = "#{MONTH_NAMES[Integer(month)]} #{year}"
    write_file(monthpage_path, "#{year}/#{month}/", month_name, {year: "#{year}", month: "#{month}"})
end
