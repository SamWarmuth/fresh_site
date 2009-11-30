require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'open-uri'
require 'rss'
before do headers "Content-Type" => "text/html; charset=utf-8" end
$content = {}


get '/' do 
	load_data
	haml :index
end
get '/:page.css' do
   content_type 'text/css', :charset => 'utf-8'
   sass params[:page].to_sym
end

def load_data()
	$content = {:today => [], :yesterday => [], :last_week => [], :earlier =>[]}
	content = ''
	[["","http://www.instapaper.com/rss/2588/CUrq0Y7Vt5yZKxhIOrDqGWxLk"],["GSR","http://www.givemesomethingtoread.com/rss"]].each do |url|
		open(url[1]) {|source| content = source.read}
		rss = RSS::Parser.parse(content, false)
		rss.items.each do |item|
			if item.date.yday == Time.now.yday
				section = :today
			elsif item.date.yday == (Time.now.yday - 1)
				section = :yesterday
			elsif Time.now.yday - item.date.yday < 7
				section = :last_week
			else
				section = :earlier
			end
			$content[section] << {:src => url[0], :title => item.title, :url => item.link, :guid => item.guid.to_s.gsub(/<\/?guid>/, ''), :description => item.comments}
		end
	end
end