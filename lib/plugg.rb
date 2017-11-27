require 'singleton'
require 'timeout'

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
      raise 'Unable to locate plugins in the provided load path'
    end

    Dispatcher.instance.start(load_path, params)
  end

  ##
  # Set the dispatch plugin timeout value
  #
  # @param integer t
  def Plugg.timeout(t = 30)
    Dispatcher.instance.set_timeout(t)
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
    Dispatcher.instance.on(evt.to_sym, params)
  end

  private

  class Dispatcher
    include Singleton

    attr_reader :registry
    attr_accessor :timeout

    ##
    # Assign a path where plugins should be loaded from
  	#
  	# @param mixed path
    # @param hash params
  	# @return void
    def start(paths, params = {})
      @registry = []

      paths.each do |path|
        if path[-1] == '/'
          path.chop!
        end

        Dir["#{path}/*.rb"].each do |f|

          require File.expand_path(f)

          begin
            instance = Object.const_get(File.basename(f, '.rb')).new

            if instance.respond_to?(:setup)
              instance.send(:setup, params)
            end

      			@registry.push(instance)

            instance = nil
          rescue Exception => e
            puts "#{f} Plugg Initialization Exception: #{e}"
          end
    		end
      end
    end

    ##
    # Set the the thread execution timeout
  	#
  	# @param integer t
  	# @return void
    def set_timeout(t)
      @timeout = t
    end

    ##
    # Initialize the dispatcher instance
  	#
  	# @return void
    def initialize
      @timeout = 30
    end

    ##
  	# Loop through all services and fire off the supported messages
  	#
  	# @param string method
  	# @return void
  	def on(method, *args, &block)
      buffer = []

      if [:initialize, :setup].include? method
        raise "#{method} should not be called directly"
      end

      threads = []

  		@registry.each do |s|
  			if s.respond_to?(method.to_sym, false)

          start_time = Time.now

          begin
        		threads << Thread.new do
              status   = true
              response = nil

              Timeout::timeout(@timeout) {
                if s.method(method.to_sym).arity == 0
                  response = s.send(method, &block)
                else
                  response = s.send(method, *args, &block)
                end
              }

              buffer << {
                plugin: s.to_s,
                return: response,
                timing: (Time.now - start_time) * 1000,
                success: status
              }
            end
          rescue Exception => e
            response = e
            status = false
          end
  			end
  		end

      threads.map(&:join)

      buffer
  	end
  end
end
