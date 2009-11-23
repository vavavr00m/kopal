require "open-uri"
class PatchedRecursiveHTTPFetcher
  attr_accessor :quiet
  
  def initialize(urls_to_fetch, level = 1, cwd = ".")
    @level = level
    @cwd = cwd
    @urls_to_fetch = RUBY_VERSION >= '1.9' ? urls_to_fetch.lines : urls_to_fetch.to_a
    #fetch() considers default one directory only so better postfix them with "/"
    #since if not, it may result in "hg/hg/lib/"
    @quiet = false
  end
  
  def ls
    @urls_to_fetch.collect do |url|
      if url =~ /^svn(\+ssh)?:\/\/.*/
        `svn ls #{url}`.split("\n").map {|entry| "/#{entry}"} rescue nil
      else
        open(url) do |stream|
          links("", stream.read)
        end rescue nil
      end
    end.flatten
  end

  def push_d(dir)
    @cwd = File.join(@cwd, dir)
    FileUtils.mkdir_p(@cwd)
  end

  def pop_d
    @cwd = File.dirname(@cwd)
  end

  #Strip fragments(#) and GET parameters.
  def strip_uri_for_fragment uri
    regex = Regexp.new('(\?|\#)(.*)$')
    [uri.gsub(regex, ''), regex.match(uri).to_s]
  end

  def extract_file_name uri
    File.basename(strip_uri_for_fragment(uri)[0])
  end

  def links(base_url, contents)
    links = []
    contents.scan(/href\s*=\s*\"*[^\">]*/i) do |link|
      link = link.sub(/href="/i, "")
      next if link =~ /svnindex.xsl$/
      next if link =~ /^(\w*:|)\/\// || link =~ /^\./
      links << File.join(strip_uri_for_fragment(base_url)[0], link)
    end
    links
  end

  def download(link)
    file_name = extract_file_name(link)
    puts "+ #{File.join(@cwd, file_name)}" unless @quiet
    open(link) do |stream|
      File.open(File.join(@cwd, file_name), "wb") do |file|
        file.write(stream.read)
      end
    end
  end

  def fetch(links = @urls_to_fetch)
    links.each do |l|
      stripped = strip_uri_for_fragment(l)[0]
      (stripped =~ /\/$/ || links == @urls_to_fetch) ? fetch_dir(l) : download(l)
    end
  end

  def fetch_dir(url)
    @level += 1
    push_d(extract_file_name(url)) if @level > 0
    open(url) do |stream|
      contents =  stream.read
      fetch(links(url, contents))
    end
    pop_d if @level > 0
    @level -= 1
  end
end