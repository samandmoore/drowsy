module ModelTestHelpers
  def connection
    @connection ||= Faraday.new(url: 'https://fake.test') do |c|
      c.request   :json
      c.use       Drowsy::JsonParser
      # uncomment for debugging
      # c.response  :logger, nil, bodies: true
      c.adapter   Faraday.default_adapter
    end
  end

  def define_model(name, uri:, parent_klass: Drowsy::Model, &block)
    connection = self.connection
    klass = Class.new(parent_klass) do
      self.uri = uri
      self.connection = connection
    end
    klass.class_eval(&block) if block_given?
    stub_const(name, klass)
  end
end
