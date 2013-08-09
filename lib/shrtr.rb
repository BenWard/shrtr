require 'rubygems'
require 'rack'
require 'yaml'

# Shrtr is a tiny class that handles redirection, via a mappings Yml file
class Shrtr

  class MissingConfigException < Exception; end


  def initialize(config = './config/shrtr.yml')
    unless File.exist? config
      raise MissingConfigException, "Cannot find #{config}"
    end
    @config = YAML.load_file config

    # Look for, load, store YML mappings
    unless @config['mappings'] && File.exist?(@config['mappings'])
      raise MissingConfigException, "No mappings configured"
    end

    mapping_config = YAML.load_file(@config['mappings'])
    @mappings = mapping_config["shorturls"]
  end

  def fallback_url
    @config["failure_url"]
  end

  def mapped_url(shortcode)
    puts shortcode
    mapping = @mappings.select { |_| _['id'] == shortcode }.first
    mapping['url'] if mapping
  end

  def call(env)
    shortcode = env["REQUEST_PATH"][1..-1]
    url = mapped_url shortcode
    if url
      [301, { "Location" => url }, ""]
    else
      [302, { "Location" => fallback_url }, ""]
    end
  end
end