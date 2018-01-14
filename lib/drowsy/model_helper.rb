module Drowsy::ModelHelper
  def self.assign_raw_attributes(model, raw_attributes)
    model.assign_attributes(translate_raw_attributes(model.class, raw_attributes))
  end

  def self.construct(klass, raw_attributes)
    klass.new(**translate_raw_attributes(klass, raw_attributes))
  end

  # re-positions associations in raw attributes for
  # proper setting on the model via #raw_$association=
  def self.translate_raw_attributes(klass, raw_attributes)
    raw_attributes.each_with_object({}) do |(key, value), memo|
      if klass.association_names.include?(key)
        memo[:"raw_#{key}"] = value
      else
        memo[key] = value
      end
    end
  end
end
