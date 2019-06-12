module Crokus

  class Ast
    def accept(visitor, arg=nil)
      name = self.class.name.split(/::/)[1]
      visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end

    def str
      ppr=PrettyPrinter.new
      self.accept(ppr)
    end
  end

  #......... AST nodes ..........
  class DesignUnit < Ast
    attr_accessor :list
    def initialize
      @list=[]
    end

    def <<(e)
      list << e
      list.flatten!
    end
  end

  class Ident < Ast
    def initialize tok
      @tok=tok
    end

    def to_s
      @tok.val
    end
  end

  class Include < Ast
    attr_accessor :name
    attr_accessor :env
    def initialize name,env=nil #local or system
      @name=name
      @env=env
    end
  end

  class Define < Ast
    attr_accessor :name,:expr
    def initialize n,e
      @name,@expr=n,e
    end
  end

  #........ types ...........

  class Type < Ast
    attr_accessor :name,:specifiers
    def initialize name
      @specifiers=[]
      @name=name
    end
  end

  class Struct < Type
    attr_accessor :decls
    def initialize name=nil
      super(name)
      @decls=[]
    end
  end

  class PointerTo < Type
    attr_accessor :type
    def initialize t
      @type=t
    end

    def name
      "#{type.name} *"
    end
  end

  class ArrayOf < Type
    attr_accessor :size
    def initialize t,size=nil
      super(t)
      @size=size
    end

    alias :type :name
  end

  class Casting < Type
    attr_accessor :type,:modifier
    def initialize type,modifier
      @type,@modifier=type,modifier
    end
  end

  class CastedExpr < Type
    attr_accessor :type,:expr
    def initialize type,expr
      @type,@expr=type,expr
    end
  end

  class Sizeof < Ast
    attr_accessor :type
    def initialize t
      @type=t
    end
  end
  #..............end of types.................

  class Decl < Ast
    attr_accessor :var,:type,:init
    def initialize type,var,init=nil
      @var,@type,@init=var,type,init
    end
  end

  class Typedef < Ast
    attr_accessor :type,:name
    def initialize type,name
      @type,@name=type,name
    end
  end

  class Function < Ast
    attr_accessor :name,:type,:args,:body
    attr_accessor :cfg
    def initialize name,ret_type,args=[],body=[]
      @name,@type=name,ret_type
      @args=args
      @body=body if body
    end
  end

  class FunctionProto < Ast
    attr_accessor :name,:type,:args
    def initialize name,ret_type,args=[]
      @name,@type=name,ret_type
      @args=args
    end
  end

  class FunCall < Ast
    attr_accessor :name,:args,:as_procedure
    def initialize name,args,as_procedure=false
      @name,@args=name,args
      @as_procedure=as_procedure
    end
  end

  class FormalArg < Ast
    attr_accessor :name,:type
    def initialize t,n
      @name,@type=n,t
    end
  end

  #......................................

  class Body < Ast
    attr_accessor :stmts
    def initialize stmts=[]
      @stmts=stmts
    end

    def <<(e)
      @stmts << e
      @stmts.flatten!
    end

    def each(&block)
      @stmts.each(&block)
    end

    def collect(&block)
      @stmts.collect(&block)
    end
  end

  class Stmt < Ast
  end

  class LabeledStmt < Stmt
    attr_accessor :label,:stmt
    def initialize label,stmt
      @label,@stmt=label,stmt
    end
  end

  class SemicolonStmt < Stmt
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end
  end

  class CommaStmt < Stmt
    attr_accessor :lhs,:rhs
    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end
  end

  class Assign < Stmt
    attr_accessor :lhs,:op,:rhs
    def initialize lhs,op,rhs
      @lhs,@op,@rhs=lhs,op,rhs
    end
  end

  class For < Stmt
    attr_accessor :init,:cond,:increment,:body
    def initialize
      @init=[]
    end
  end

  class While < Stmt
    attr_accessor :cond,:body
    def initialize cond,body
      @cond,@body=cond,body
    end
  end

  class DoWhile < Stmt
    attr_accessor :cond,:body
    def initialize cond,body=[]
      @cond,@body=cond,body
    end
  end

  class If < Stmt
    attr_accessor :cond,:body,:else
    def initialize cond,body,else_=nil
      @cond,@body,@else=cond,body,else_
    end
  end

  class Else < Stmt
    attr_accessor :body
    def initialize body=[]
      @body=body
    end
  end

  class Switch < Stmt
    attr_accessor :expr,:cases
    def initialize expr,cases=[]
      @expr,@cases=expr,cases
    end
  end

  class Case < Stmt
    attr_accessor :expr,:body
    def initialize e,body
      @expr,@body=e,body
    end
  end

  class Accu < Assign
    def initialize lhs,tok,rhs=nil
      super(lhs,tok,rhs)
    end
  end

  class PostFixAccu < Assign
    def initialize lhs,tok
      super(lhs,tok,nil)
    end
  end

  class Return < Stmt
    attr_accessor :expr
    def initialize e
      @expr=e
    end
  end

  class Break < Stmt
  end

  class Goto < Stmt
    attr_accessor :label
    def initialize label
      @label=label
    end
  end

  class Switch < Stmt
  end

  class LabelledStmt < Stmt
    attr_accessor :stmt
    def initialize stmt
      @stmt=stmt
    end
  end

  #.................... expressions...................
  class Expr < Ast#decorative
  end

  class CondExpr < Ast
    attr_accessor :cond,:lhs,:rhs
    def initialize cond,lhs,rhs
      @cond,@lhs,@rhs = cond,lhs,rhs
    end
  end

  class Binary < Expr
    attr_accessor :op,:lhs,:rhs
    def initialize lhs,op,rhs
      @lhs,@op,@rhs = lhs,op,rhs
    end
  end

  class Unary < Expr
    attr_accessor :op,:rhs,:postfix
    def initialize op,rhs,postfix=nil
      @op,@rhs=op,rhs
      @postfix=postfix
    end
  end

  class Deref < Expr
    attr_accessor :expr
    def initialize e
      @expr = e
    end
  end

  class AddressOf < Expr# &
    attr_accessor :expr
    def initialize expr
      @expr=expr
    end
  end

  class Indexed < Expr
    attr_accessor :lhs,:rhs
    def initialize l,r
      @lhs,@rhs=l,r
    end
  end

  class Dotted< Expr
    attr_accessor :lhs,:rhs
    def initialize l,r
      @lhs,@rhs=l,r
    end
  end

  class Parenth < Expr
    attr_accessor :expr
    def initialize e
      @expr=e
    end
  end

  class Arrow < Expr
    attr_accessor :lhs,:rhs
    def initialize l,r
      @lhs,@rhs=l,r
    end
  end

  class ArrayOrStructInit < Expr
    attr_accessor :elements
    def initialize elements=[]
      @elements=elements
    end
  end

  # literals
  class Literal < Ast
    def initialize tok
      @tok=tok
    end

    def to_s
      @tok.val
    end
  end

  class IntLit < Literal
  end

  class FloatLit < Literal
  end

end #module
