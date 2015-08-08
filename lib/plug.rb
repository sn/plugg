require 'singleton'

module Plugg

  ##
  # Set the source directory to load the plugins from
  #
  # @param mixed path
  def Plug.source(path)

    load_path = []

    if !path.kind_of?(Array)
      if File.directory?(path)
        load_path << path
      end
    else
      path.select! do |p|
        File.directory?(p)
      end

      load_path.concat path
    end

    if load_path.empty?
      raise "Plugin load paths contain no valid directories"
    end

    Dispatcher.plugin_path = load_path
  end

  ##
  # Get the current registry
  #
  # @return array
  def Plug.registry
    Dispatcher.instance.registry
  end

  ##
  # Send an event to the plugin registry
  #
  # @param symbol evt
  # @param hash params
  # @return mixed
  def Plug.send(evt, params = {})
    Dispatcher.instance.on(evt, params)
  end

  class Dispatcher
    include Singleton

    attr_reader :registry

    @@plugin_path = []

    ##
    # Assign a path where plugins should be loaded from
  	#
  	# @param string path
  	# @return void
    def self.plugin_path=(path)
      @@plugin_path = path
    end

    ##
    # Initialize the dispatcher and load the plugin instances
  	#
  	# @return void
    def initialize
      @registry = []

      @@plugin_path.each do |path|
        if path[-1] == '/'
          path.chop!
        end

        Dir["#{path}/*.rb"].each do |f|

          require File.expand_path(f)

          begin
      			@registry.push(
      				Object.const_get(File.basename(f, '.rb')).new
      			)
          rescue Exception => e
            puts "#{f} Initialization Exception."
          end
    		end
      end
    end

    ##
  	# Loop through all services and fire off the supported messages
  	#
  	# @param string method
  	# @return void
  	def on(method, *args, &block)
      buffer = []

  		@registry.each do |s|
  			if s.respond_to?(method.to_sym, include_private = false)

          start = Time.now
          response = nil

          begin
            if s.method(method.to_sym).arity == 0
              response = s.send(method, &block)
            else
              response = s.send(method, *args, &block)
            end
          rescue Exception => e
            response = e
          end

          buffer << {
            :plugin => s.to_s,
            :return => response,
            :timing => (Time.now - start) * 1000
          }
  			end
  		end

      buffer
  	end
  end
end
