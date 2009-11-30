require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'rss'
before do headers "Content-Type" => "text/html; charset=utf-8" end
$content = {:today => [], :yesterday => [], :earlier =>[]}


get '/' do 
	load_data
	haml :index
end
get '/:page.css' do
   content_type 'text/css', :charset => 'utf-8'
   sass params[:page].to_sym
end

def load_data()
	$content = {:today => [], :yesterday => [], :earlier =>[]}
	content = ''
	["http://www.instapaper.com/rss/2588/CUrq0Y7Vt5yZKxhIOrDqGWxLk","http://www.fbcal.com/cal/1607400071/b1bfb810885ff34b9c45f4c6-1607400071/birthday/rss/"].each do |url|
		open(url) {|source| content = source.read}
		rss = RSS::Parser.parse(content, false)
		rss.items.each do |item|
			if item.date.yday == Time.now.yday
				$content[:today] << {:title => item.title, :url => item.link, :guid => item.guid.to_s.gsub(/<\/?guid>/, ''), :description => item.comments}
			elsif item.date.yday == (Time.now.yday - 1)
				$content[:yesterday] << {:title => item.title, :url => item.link, :guid => item.guid.to_s.gsub(/<\/?guid>/, ''), :description => item.comments}
			else
				$content[:earlier] << {:title => item.title, :url => item.link, :guid => item.guid.to_s.gsub(/<\/?guid>/, ''), :description => item.comments}
			end
		end
	end
end