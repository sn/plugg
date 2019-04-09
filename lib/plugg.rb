require 'singleton'
require 'timeout'
require 'ostruct'

module Plugg
  ##
  # Set the source directory to load the plugins & dependencies from
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
      raise 'Unable to locate plugins in the provided load paths'
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

  class DispatchResponder
    attr_reader :plugin
    attr_reader :meta
    
    def initialize(plugin = nil)
      @meta = OpenStruct.new

      @meta.start_time = Time.now
      @meta.plugin     = plugin
      @meta.response   = nil
      @meta.runtime    = nil
      @meta.error      = nil
    end

    def trap(timeout = 5)
      Timeout::timeout(timeout) {
        begin  
          @meta.response = yield
        rescue Exception => e
          @meta.error = e
        end
      }

      @meta.runtime = (Time.now - @start_time) * 1000
    end

    def finalize
      if @meta.plugin.respond_to?(:after)
        @meta.plugin.send(:after) 
      end
    end

    def ok? 
      @meta.error.nil?
    end

    def error
      @meta.error
    end

    def to_h
      defaults = {
        plugin:   @meta.plugin.to_s,
        runtime:  @meta.runtime,
        response: @meta.error,
        success:  ok?
      }

      defaults
    end
  end

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

            # `before` event callback
            if instance.respond_to?(:before)
              instance.send(:before)
            end

            # `setup` method
            if instance.respond_to?(:setup)
              instance.send(:setup, params)
            end

            @registry.push(instance)
            
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
    # Initialize the dispatcher instance with a default timeout of 5s
  	#
  	# @return void
    def initialize
      @timeout = 5
    end

    ##
  	# Loop through all services and fire off the supported messages
  	#
  	# @param string method
  	# @return void
  	def on(method, *args, &block)

      if [:initialize, :before, :setup, :after].include? method
        raise "#{method} should not be called directly"
      end

      buffer  = [] # Container for the response buffer  
      threads = [] # Container for the execution threads

  		@registry.each do |s|
        if s.respond_to?(method.to_sym, false)
          threads << Thread.new do 
            responder = DispatchResponder.new(s)
          
            responder.trap(@timeout) do 
              if s.method(method.to_sym).arity == 0
                s.send(method, &block)
              else
                s.send(method, *args, &block)
              end
            end

            responder.finalize

            buffer << responder.to_h
          end
  			end
  		end

      threads.map(&:join)

      buffer
  	end
  end
end