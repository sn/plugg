require 'singleton'

module Plugg

  ##
  # Set the source directory to load the plugins from
  #
  # @param hash params
  # @param mixed path
  def Plugg.source(path, params = {})

    load_path = []

    if !path.kind_of?(Array)
      if File.directory?(path)
        load_path << path
      end
    else
      path.select! do |p|
        File.directory?(p)
      end

      load_path.concat(path)
    end

    if load_path.empty?
      raise "Plugin load paths contain no valid directories"
    end

    Dispatcher.start(load_path, params)
  end

  ##
  # Get the current registry
  #
  # @return array
  def Plugg.registry
    Dispatcher.instance.registry
  end

  ##
  # Send an event to the plugin registry
  #
  # @param symbol evt
  # @param hash params
  # @return mixed
  def Plugg.send(evt, params = {})
    Dispatcher.instance.on(evt, params)
  end

  class Dispatcher
    include Singleton

    attr_reader :registry

    @@plugin_path = []
    @@params = {}

    ##
    # Assign a path where plugins should be loaded from
  	#
  	# @param mixed path
    # @param hash params
  	# @return void
    def self.start(path, params = {})
      @@plugin_path = path
      @@params = params
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
            instance = Object.const_get(File.basename(f, '.rb')).new

            if instance.respond_to?(:set_params)
              instance.send(:set_params, @@params)
            end

      			@registry.push(
              instance
      			)

            instance = nil
          rescue Exception => e
            puts "#{f} Initialization Exception: #{e}"
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

      if [:initialize, :set_params].include? method
        raise "#{method} should not be called this way"
      end

  		@registry.each do |s|
  			if s.respond_to?(method.to_sym, false)

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
