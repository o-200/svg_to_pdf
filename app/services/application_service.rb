class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  class Result
    attr_accessor :value,
                  :errors

    def initialize(value: nil, errors:)
      @value = value
      @errors = errors
    end

    def success?
      errors.empty?
    end

    def failure?
      !success?
    end
  end
end
