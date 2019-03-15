module Crokus
  class Cleaner
    def clean str_c
      str_c.gsub!(";;",";")
      str_c.gsub!(";)",")")
      str_c.gsub(/\n\s*\{/,"{")
    end
  end
end
