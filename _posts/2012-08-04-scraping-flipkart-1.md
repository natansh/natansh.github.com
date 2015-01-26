---
layout: post
title: Scraping Flipkart - Part 1
---

Scraping is an extremely brittle technique, but it's also an invaluable tool if used correctly. For example, many sites don't have an API, and occasionally, the information one needs can be better extracted by using programmatic techniques. I was pretty clear about the concepts involved in scraping, but when it came to implementation, I didn't know where I could start.

So last week, I decided to embark on a simple experiment - to scrape Flipkart using a Ruby toolbox. I didn't want to blindly spider Flipkart (although I found an interesting library called [Anemone](https://github.com/chriskite/anemone/) that can do just that). I was out looking for structured data of items that are present on the Flipkart store. I also wondered what data would be okay to scrape, and what would be considered an intrusion. In the end, I settled on a simple solution - anything not mentioned in the `robots.txt` file (which acts as somewhat of an exclusion list for bots and web crawlers) would be fair game.

I visited Flipkart's `robot.txt` file at [http://www.flipkart.com/robots.txt](http://www.flipkart.com/robots.txt) . It was a pretty uneventful visit, until I reached the end of the file, which mentioned - 

    Sitemap: http://www.flipkart.com/sitemap/sitemap_index.xml

I could've kicked myself for not thinking about the sitemap earlier, but then, better late than never. So I visited the XML page, and it was like hitting the jackpot. It had `89` gzipped files covering each category present on flipkart. Opening one up showed the individual items in the category. Some categories were divided into multiple files, but it looked like this was everything that Flipkart had to offer.

After finding the perfect source for data, I digged into finding the correct tools to extract the data. I came across [Nokogiri](http://nokogiri.org/), which is an XML parser. For HTTP requests, I decided to give [HTTParty](https://github.com/jnunemaker/httparty) a try, and for unzipping the files, I used `zlib`. For persistence, I decided to store data in JSON format, so I used `multi_json`.

The code was surprisingly terse, and I was able to come up with it within an hour. It first downloads the main sitemap and parses a list of archives in it. It then sequentially downloads the archives  that hold individual links, extracts them and adds the list of links present in them to the results.

{% highlight ruby lineanchors %}
require 'nokogiri'
require 'httparty'
require 'zlib'
require 'multi_json'

# Get the main document
document = Nokogiri::XML(HTTParty.get('http://www.flipkart.com/sitemap/sitemap_index.xml').body)

# Extract the archive link list
xml_archives = document.css('sitemap loc').inject([]) do |result, node|
  result.push(node.children[0].content)
end

sitemap = xml_archives.inject({}) do |result, archive_url|

  p "> GET " + archive_url
  response = HTTParty.get(archive_url)

  p "Unzipping"
  string = StringIO.new(response.body.to_s)
  binding.pry
  unzipped = Zlib::GzipReader.new(string).read

  p "Selecting details"
  url_list = []

  # Using a SAX parser instead of CSS selectors because CSS
  # selectors are mind-numbingly slow in comparison.
  archive_document = Nokogiri::XML::Reader(unzipped)
  archive_document.each do |node|
    # node_type == 1 is for the opening tag
    if node.name == 'loc' && node.node_type == 1
      # Read content in between the `loc` tag.
      node.read
      print '#' 
      url_list.push(node.value)
    end 
  end 

  result[archive_url] = url_list 
  result
end

File.open('sitemap.dump', 'w') do |file|
  file.write(MultiJson.encode(sitemap))
end
{% endhighlight %}

With the data I have, several interesting metrics can be calculated. However, I decided to calculate the simplest, the number of unique items in Flipkart -

{% highlight ruby lineanchors %}
sitemap.inject(0) do |result, elem|
  result += elem[1].size  
end  
{% endhighlight %}

Flipkart currently has 1416441 listed items. That's approximately 1.5 _million_ unique items.

Next up, I am planning to do a more thorough scrape of individual items. By calculation, if I do 1 request/second, it will take me 16.3 days to scrape Flipkart completely. Let's see. :-)
