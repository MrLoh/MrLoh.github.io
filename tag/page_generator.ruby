# Read Tags into array
tags = []
taglist_path = File.expand_path("../../_site/tag/list.txt", __FILE__)
File.open(taglist_path, 'r') do |f1|
    while tag = f1.gets
        tag = tag.strip
        unless tag == "" || tag == "\n"
            tags += [tag]
        end
    end
end
puts "found following tags on site: #{tags.join(', ')} \n\n"

# Create .md files for each tag
for tag in tags
    tagpage_path = File.expand_path("../#{tag.downcase}.md", __FILE__)
    unless File.exists?(tagpage_path)
        File.open(tagpage_path, 'w') do |f2|
          f2.puts "---"
          f2.puts "layout: tagpage"
          f2.puts "title: #{tag}"
          f2.puts "---"
        end
        puts "created #{tag.downcase}.md"
    else
        puts "found #{tag.downcase}.md, did nothing"
    end
end
