class Code

  attr_accessor :indent,:lines

  def initialize str=nil
    @lines=[]
    (@lines << str) if str
    @indent=0
  end

  def <<(thing)
    if (code=thing).is_a? Code
      code.lines.each do |line|
        @lines << " "*@indent+line.to_s
      end
    elsif thing.is_a? Array
      thing.each do |kode|
        @lines << kode
      end
    elsif thing.nil?
    else
      @lines << " "*@indent+thing.to_s
    end
  end

  def finalize dot=false
    if dot
      return @lines.join('\n')
    end
    @lines.join("\n") if @lines.any?
  end

  def newline
    @lines << " "
  end

  def save_as filename,verbose=true,sep="\n"
    str=self.finalize
    File.open(filename,'w'){|f| f.puts(str)}
    #puts "saved code in file #{filename}" if verbose
    return filename
  end

  def size
    @lines.size
  end


end
