class Token

  attr_accessor :kind,:val,:pos

  def initialize tab
    @kind,@val,@pos=*tab
  end

  def is? kind
    case kind
    when Symbol
      return @kind==kind
    when Array
      for sym in kind
        return true if @kind==sym
      end
      return false
    else
      raise "wrong type during lookahead"
    end
  end

  def accept visitor,arg=nil
    visitor.visitToken(self,arg)
  end

  def self.create str
    Token.new [:id,str,[0,0]]
  end

  def to_s
    val
  end

  def inspect
    "(#{kind},#{val},#{pos})"
  end

  alias :str :val
end

INT  = Token.new  [:int    ,'int'   ,['na','na']]
ONE  = Token.new  [:int_lit,'1'     ,['na','na']]
ZERO = Token.new  [:int_lit,'0'     ,['na','na']]
T42  = Token.new  [:int_lit,'42'    ,['na','na']]
DUMMY= Token.new  [:id     ,''      ,['na','na']]
EQUAL= Token.new  [:eq     ,'=='    ,['na','na']]
ASSIGN= Token.new [:assign ,'='     ,['na','na']]
XOR   = Token.new [:xor    ,'^'     ,['na','na']]
AND   = Token.new [:and    ,'&'     ,['na','na']]
MOD   = Token.new [:mod    ,'%'     ,['na','na']]
SUB   = Token.new [:sub    ,'%'     ,['na','na']]
GT    = Token.new [:gt     ,'>'     ,['na','na']]
