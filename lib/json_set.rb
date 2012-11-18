# serialization

class JsonSet
  # this might be the database default and we should plan for empty strings or nils
  def self.load(s)
    Set.new(s.present? ? JSON.load(s) : []).to_a
  end

  # this should only be nil or an object that serializes to JSON (like a hash or array)
  def self.dump(ary)
    JSON.dump(ary ? ary.delete_if { |e| e.blank? } : [])
  end
  
  def self.validate(record, attr, value, valid)
    if value.nil? || value.empty?
      record.errors.add(attr, 'is missing')
    else
      invalid = value.select { |e| !valid.include?(e) }
      if !invalid.empty?
        record.errors.add(attr, "contains invalid entries: #{invalid.join(', ')}")
      end
    end
  end
end