require_relative 'code'
require_relative 'transformer'

module Crokus

  class TrojanInserter < Transformer

    def insert ast
      @nb_trojans=0
      new_ast=transform(ast)
      if @nb_trojans>0
        puts "insertion succeeded : #{@nb_trojans} trojan(s)"
        return new_ast
      else
        puts "insertion failed"
      end
      nil
    end

    def new_ident
      @tmp_id||=0
      tok=Token.create "$"+@tmp_id.to_s
      @tmp_id+=1
      Ident.new(tok)
    end

    def visitFunction func,args=nil
      puts "[+] func #{func.name}"
      func_troj=super(func,args)
      success=insert_trojan(func_troj)
      @nb_trojans+=1 if success
      func_troj
    end

    def bodies_collect func
      bodies=[]
      bodies << func.body
      bodies << bodies_rec_collect(func.body)
      bodies.flatten!
      bodies
    end

    def bodies_rec_collect body
      bodies=[]
      body.each do |stmt|
        case if_=for_=while_=dowhile_=switch_=stmt
        when If
          bodies << if_.body
          if else_=if_.else
            bodies << else_.body
          end
        when For
          bodies << for_.body
        when While, DoWhile
          bodies << stmt.body
        when Switch
          bodies << switch_.cases.collect{|case_| case_.body}
        end
      end
      result = []
      result << bodies
      result << bodies.collect{|bod| bodies_rec_collect(bod)}
      result.flatten
    end

    def insert_trojan func
      bodies=bodies_collect(func)
      puts "#bodies = #{bodies.size}"
      target_body=bodies.sample
      stmts=target_body.stmts
      nb_decls=stmts.select{|stmt| stmt.is_a? Decl}.size
      pos=rand(nb_decls..stmts.size-1)
      if trojan=build_trojan(func)
        target_body.stmts=stmts.insert(pos,trojan)
        return success=true
      end
      success=false
    end

    INT_TYPE=Type.new(INT)

    def build_trojan func
      trojan=Body.new
      anchor_var=choose_anchor(func)
      return unless anchor_var
      u_=Ident.new(Token.create("u_"))
      v_=Ident.new(Token.create("v_"))
      i_=Ident.new(Token.create("i_"))
      trojan << Assign.new(v_,ASSIGN,anchor_var)
      trojan<< if_trigger=build_trigger(func)
      return unless if_trigger
      trojan << Assign.new(anchor_var,ASSIGN,v_)
      ast_trojan=Crokus::Parser.new.parse(TROJAN)
      body_trojan=ast_trojan.list.first.body # root/func/body
      if_trigger.body=body_trojan
      func.body.stmts.insert(0,Decl.new(INT_TYPE,u_))
      func.body.stmts.insert(0,Decl.new(INT_TYPE,v_))
      func.body.stmts.insert(0,Decl.new(INT_TYPE,i_))
      trojan
    end

    def choose_anchor func
      # find a var of type int in func local declaration
      decls=func.body.select{|stmt| stmt.is_a? Decl}
      int_decls=decls.select{|decl| decl.type.name.is_a?(Token) && decl.type.name.kind==:int}
      vars=int_decls.map{|decl| decl.var}
      return vars.sample
    end

    TROJAN=%{
      void trojan(){
        u_=v_>0?v_:-v_;
        for(i_=0;i_<339;i_++)
          u_=(u_%2==0)?u_/=2:3*u_+1;
        while u_>1 u_=u_/2;
        v_*=u_;
      }
    }

    def build_trigger func
      args=find_int_arg(func)
      return unless args.size>1
      cond=Binary.new(Parenth.new(Binary.new(args[0],AND,args[1])),EQUAL,T42)
      If.new(cond,nil)
    end

    def find_int_arg func
      func.args.select do |arg|
        (tok=arg.type.name).is_a?(Token) && tok.is?(:int)
      end
    end

  end
end
