module Celluloid
  # Celluloid::Future objects allow methods and blocks to run in the
  # background, their values requested later
  class Future
    include Celluloid
    include Celluloid::Logger

    attr_reader :address

    def self.new(*args, &block)
      future = super
      future.async.execute_block
      future
    end

    def initialize(*args, &block)
      @address = Celluloid.uuid
      @result = nil
      @ready = false
      @condition = Celluloid::Condition.new

      @block = block
      @args = args
    end

    def execute_block
      result = @block.call(*@args)
      @condition.signal(result)
    end

    # Check if this future has a value yet
    def ready?
      @ready
    end

    # Obtain the value for this Future
    def value(timeout = nil)
      if !ready?
        @result = @condition.wait(timeout)
        @ready = true
      end
      @result
    end
    alias_method :call, :value

    # Signal this future with the given result value
    def signal(value)
      raise "the future has already happened!" if @ready
      @result = value
      @ready = true
      @condition.signal(value)
    end
    alias_method :<<, :signal

    # Inspect this Celluloid::Future
    alias_method :inspect, :to_s
  end
end
