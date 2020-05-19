module Crokus
  class Cleaner
    def clean str_c
      str_c.gsub!(";)",")")
      str_c.gsub!(/\n+\s*\;/,";")
      str_c.gsub!(/\;\s*\:/,":")
      str_c.gsub!(/\n\s+\{/,"{")
      str_c.gsub!(/\;+/,";")
      str_c
    end

    def debug str_c
      puts "hit a key"
      $stdin.gets.chomp
      puts str_c
    end
  end
end
