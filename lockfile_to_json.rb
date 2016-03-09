require "octokit"
require "fileutils"
require "base64"
require "bundler"
require "json"

abort("Please set ENV[\"GITHUB_USERNAME\"] and/or ENV[\"GITHUB_PASSWORD\"] and try again") unless ENV["GITHUB_USERNAME"] && ENV["GITHUB_USERNAME"]
abort("Oops, looks like you forgot to specify a Github organization name. Please try again.") unless ARGV.size >= 1

Octokit.configure do |c|
  c.login = ENV["GITHUB_USERNAME"]
  c.password = ENV["GITHUB_PASSWORD"]
end

TMP_DIR = ".bundle"
FileUtils.mkdir TMP_DIR

r = Octokit.search_code("Gemfile.lock in:path user:#{ARGV[0]} NOT migrations", :per_page => 100)

repositories = []
specs = {}

r.items.each do |i|
  f = Octokit.content(i.repository.full_name, path: i.path)
  d = Base64.decode64(f.content)
  gemfile = Bundler::LockfileParser.new(d)

  tmp_hash = {
    :name => "#{i.repository.name}",
    :sources => gemfile.sources,
    :specs => gemfile.specs,
    :dependencies => gemfile.dependencies,
    :platforms => gemfile.platforms,
    :bundler_version => gemfile.bundler_version
  }
  repositories << tmp_hash

  tmp_hash[:specs].each do |d|
    gemname = d.to_s.split(" ").first
    version = d.to_s.split(/[()]/).last
    specs[gemname] ||= { :versions => [], :usage => [] }
    specs[gemname][:versions] << version unless specs[gemname][:versions].include? version
    specs[gemname][:usage] << tmp_hash[:name]
  end

  puts "Parsing " + i.repository.name + "...\nDONE."
end
repositories.sort_by! { |h| h[:name] }

File.open("data.json", "w") do |f|
  puts "Writing data.json..."
  data_hash = { "repositories" => repositories,
                "gems" => specs.map { |k,v| { name: k, versions: v[:versions].sort, usage: v[:usage].sort }} }
  f.write(data_hash.to_json)
end

puts "Cleaning up..."
FileUtils.rm_rf(TMP_DIR) if File.exists?(TMP_DIR)
puts "Finished."
