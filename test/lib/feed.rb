class Feed < ActiveRecord::Base

  #
  # new, per-attribute validation: the keyword must be "attribute" or "traditional"
  validates do
    on :keyword do |keyword|
      next unless language == "mode1"

      !!keyword && keyword.length >= 5
    end

    on :keyword do
      next unless language == "mode2"

      !!keyword && keyword.length >= 5
    end


    on :keyword do
      next unless language == "mode3"

      next if keyword && keyword.length >= 5
      raise "Ho! We are invalid"
    end
  end
  
  #
  # traditional validation: the keyword must be at least 5 chars.
  validate do |rec|
    next unless rec.language == "traditional"
    if !rec.keyword || rec.keyword.length < 5
      rec.errors.add(:keyword, "Must be larger than 5")
    end
  end
end
