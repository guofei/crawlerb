require 'mechanize'

agent = Mechanize.new
agent.max_history = nil # unlimited history
stack = agent.get(ARGV[0]).links

while l = stack.pop
  begin
    next unless l.uri
    host = l.uri.host
    next unless host.nil? or host == agent.history.first.uri.host
    next if agent.visited? l.href
  rescue Mechanize::UnsupportedSchemeError => e
    p l
    next
  end

  puts "crawling #{l.uri}"
  begin
    page = l.click
    next unless Mechanize::Page === page
    stack.push(*page.links)
  rescue Mechanize::ResponseCodeError
  end
end
