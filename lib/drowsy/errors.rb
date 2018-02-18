module Drowsy
  class Error < StandardError; end

  class ConnectionError < Error; end

  class ResponseError < Error
    def initialize(result)
      @result = result
    end

    def status
      result.status
    end

    def raw_response
      result.response
    end

    def to_s
      "Request Failed.  HTTP status code:  #{status}."
    end

    private

    attr_reader :result
  end

  class UnauthorizedError < ResponseError; end
  class ForbiddenError < ResponseError; end
  class ResourceNotFound < ResponseError; end
  class ResourceInvalid < ResponseError
    delegate :errors, to: :result
  end
  class ClientError < ResponseError; end
  class ServerError < ResponseError; end
  class UnknownResponseError < ResponseError; end

  class ModelInvalid < Error
    def initialize(model)
      @model = model
      super(model.errors.full_messages.to_sentence)
    end
  end
end
