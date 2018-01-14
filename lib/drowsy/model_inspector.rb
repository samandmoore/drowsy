module Drowsy::ModelInspector
  def self.inspect(model)
    "#<#{model.class}(#{model.class.uri})#{inspect_attributes(model.attributes)}#{inspect_associations(model.associations)}>"
  end

  def self.inspect_attributes(attributes)
    attributes.map { |k, v| " #{k}: #{v.inspect}" }.join('')
  end

  def self.inspect_associations(associations)
    associations
      .map { |k, v| " #{k}: #{inspect_association(v)}" }
      .join('')
  end

  def self.inspect_association(association)
    if association.respond_to? :each
      if association.empty?
        "[]"
      else
        "[...]"
      end
    elsif association.present?
      "#<#{association.class} id: #{association.id}"
    else
      "nil"
    end
  end
end
