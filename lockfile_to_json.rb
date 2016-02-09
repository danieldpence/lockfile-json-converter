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

FileUtils.rm_rf(TMP_DIR) if File.exists?(TMP_DIR)
FileUtils.mkdir TMP_DIR

r = Octokit.search_code("Gemfile.lock in:path user:#{ARGV[0]} NOT migrations", :per_page => 100)

data_hash = {}
data_hash["repositories"] = []

r.items.each do |i|
  f = Octokit.content(i.repository.full_name, path: i.path)
  d = Base64.decode64(f.content)
  gemfile = Bundler::LockfileParser.new(d)

  tmp_hash = {
    :name => "#{i.repository.name}",
    :source => gemfile.sources,
    :specs => gemfile.specs,
    :dependencies => gemfile.dependencies,
    :platforms => gemfile.platforms,
    :bundler_version => gemfile.bundler_version
  }
  data_hash["repositories"] << tmp_hash

  puts "Parsing " + i.repository.name + "...\nDONE."

  File.open("data.json", "w") do |f|
    f.write(data_hash.to_json)
  end
end

puts "#{data_hash["repositories"].size}" + " Gemfile.lock files converted to JSON"
