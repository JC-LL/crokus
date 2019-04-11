require_relative "../lib/crokus"

puts "running parser tests"

unless ARGV.first=="--all"
  pp_c_files=Dir["*_pp.c"]
  puts "suppressing generated _pp.c files : #{pp_c_files.size}"
  pp_c_files.each do |c|
    system("rm -f #{c}")
  end
end

compiler=Crokus::Compiler.new
compiler.options[:mute]=true
files=Dir["test_*.c"].sort
nb_tests=files.size
max_length=files.max_by{|s| s.length}.length+4
success=0

files.each do |c|
  begin
    print "parsing "+(c+" ").ljust(max_length,".")
    result=compiler.compile c
    status=result==true ? "OK": "nok"
    puts status.rjust(3)
    success+=1
  rescue Exception
    puts
  end
end
percent=(success.to_f/nb_tests*100).round(2)
puts
puts "success : #{percent}%"
