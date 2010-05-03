require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'open-uri'
require 'rss'
before do headers "Content-Type" => "text/html; charset=utf-8" end
$content = {}


get '/' do 
	redirect '/about'
end
get '/fresh' do
	params[:page] = 'Fresh'
	load_data
	haml :fresh
end
get '/:page.css' do
   content_type 'text/css', :charset => 'utf-8'
   sass params[:page].to_sym
end
get '/portfolio' do
	params[:page] = 'Portfolio'
	haml :portfolio
end
get '/about' do
	params[:page] = 'About'
	haml :about
end
get '/blog' do
  load_blog
  params[:page] = 'Blog'
  haml :blog
end

def load_data()
	$content = {:today => [], :yesterday => [], :last_week => [], :earlier =>[]}
	content = ''
	[["SW","http://pdb.samwarmuth.com/posts.xml"],["TBL","http://blog.samwarmuth.com/rss"],["INS","http://www.instapaper.com/rss/2588/loMH7cAuH9BmL16bOe2G4wXht0"],["GSR","http://www.givemesomethingtoread.com/rss"]].each do |url|
    begin
      open(url[1]) {|source| content = source.read}
    rescue OpenURI::HTTPError
       next
     end
    rss = RSS::Parser.parse(content, false)
    next if rss.nil?
    rss.items.each do |item|
      next if Time.now.year != item.date.year
      if item.date.yday == Time.now.yday
        section = :today
      elsif item.date.yday == (Time.now.yday - 1)
        section = :yesterday
      elsif Time.now.yday - item.date.yday < 7
        section = :last_week
      elsif Time.now.yday - item.date.yday < 30
        section = :earlier
      end
      $content[section] << {:src => url[0], :title => item.title, :url => item.link, :guid => item.guid.to_s.gsub(/<\/?guid>/, ''), :description => item.description.to_s.gsub(/<\/?blockquote>/, '')} if section
    end
  end
end

def load_blog
  begin
    content = ''
    open("http://blog.samwarmuth.com/rss") {|source| content = source.read}
    rss = RSS::Parser.parse(content, false)
    @content = rss.items
  rescue
    @content = "Error Loading Blog."
  end
end