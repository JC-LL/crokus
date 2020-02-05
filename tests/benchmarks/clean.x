#!/usr/bin/env ruby

home=Dir.pwd
Dir.glob("**/*/").each do |dir|
	puts "=> processing #{dir}"
	Dir.chdir dir
	deletables=[]
	deletables << Dir.glob("*.ir")
	deletables << Dir.glob("*_pp.c")
	deletables << Dir.glob("*.dot")
	pp deletables.flatten!
	deletables.each{|file| File.delete(file)}
	Dir.chdir home # back to where we started
end
