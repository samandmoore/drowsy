module Drowsy
  class Error < StandardError; end

  class ConnectionError < Error; end

  class ResponseError < Error
    def initialize(response)
      @response = response
    end

    def status
      response.status
    end

    def to_s
      "Request Failed.  HTTP status code:  #{status}."
    end

    private

    attr_reader :response
  end

  class UnauthorizedError < ResponseError; end
  class ForbiddenError < ResponseError; end
  class ResourceNotFound < ResponseError; end
  class ResourceInvalid < ResponseError
    def errors
      response.body[:errors]
    end
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
