require 'yaml'
require 'distribution'

require_relative 'cfg_printer_c'

class Hash
  def sample
    k=keys.sample
    [k,self[k]]
  end
end

module Crokus

  class RandomGen
    attr_accessor :cfg

    def run params
      puts "[+] running random C generation"
      puts " |-->[+] reading parameters file '#{params}'"
      @params=YAML.load(File.read(params))
      init_cfg
      init_random_generators
      create_inputs
      create_outputs
      create_variables
      create_internal_arrays
      create_output_assigns
      create_cfg
      gen_dot # to see the structure, before hacking the content
      populate_all
      generate_c
      #print_infos
    end


    def print_infos
      puts " |-->[+] infos about CFG :"
      puts "      |-->[+] #basic blocks : #{@cfg.size}"
    end

    def gen_dot
      @cfg.print verbose=false
    end

    def init_cfg
      @cfg=CFG.new(@params["name"])
      @current=@cfg.starter
    end

    def init_random_generators
      puts " |-->[+] init parameterized random generators"
      @rng={}
      @params.each do |key,val|
        if key.start_with? "avg_"
          name=key[4..-1]
          @rng[name]=Distribution::Normal.rng(mean=val,sigma=0.5) #sigma=1 ?
        end
      end
    end

    def register_readables ary
      @readables||=[]
      @readables << ary
      @readables.flatten!
    end

    def create_inputs
      name="in_0"
      @inputs=(1..@params["nb_inputs"]).map{|idx| Ident.new(Token.create name=name.succ)}
      register_readables @inputs
      @cfg.infos["inputs"]=@inputs
    end

    def create_outputs
      name="out_0"
      @outputs=(1..@params["nb_outputs"]).map{|idx| Ident.new(Token.create name=name.succ)}
      @cfg.infos["outputs"]=@outputs
    end

    def create_variables
      name="`" # succ is 'a'
      @vars=(1..@params["nb_int_vars"]).map{|idx| Ident.new(Token.create name=name.succ)}
      register_readables @vars
      @cfg.infos["int_vars"]=@vars
    end

    def create_output_assigns
      @cfg.infos["output_assigns"]||=[]
      @outputs.each do |ident|
        @cfg.infos["output_assigns"] << {ident => create_expression}
      end
    end

    def create_internal_arrays
      @cfg.infos["internal_arrays"]||=[]
      (1..@params["nb_int_arrays"]).each do |idx|
        size=@rng["size_int_arrays"].call.to_i
        size=IntLit.new(Token.create(size.to_s))
        @cfg.infos["internal_arrays"] << {Ident.new(Token.create("t#{idx}")) => size}
      end
    end

    def create_cfg
      puts " |-->[+] building cfg"
      while @cfg.size < @params["nb_basic_blocks"]
        rec_create_bbs
      end
    end

    def rec_create_bbs level=0
      if @cfg.size < @params["nb_basic_blocks"]
        type = [:plain,:if,:while,:for].sample
        case type
        when :plain
          gen_plain_block(level)
        when :if
          gen_if_block(level)
        when :while
          gen_while_block(level) if @params["accept_while_loops"]
        when :for
          gen_for_block(level)
        else
          raise "unknown cfg type : #{type}"
        end
      end
    end

    def gen_plain_block level
      @cfg << bb=BasicBlock.new
      @current.to bb
      @current=bb
    end

    def gen_if_block level
      @current.infos[:cond]=create_condition
      @current.infos[:start_if]=true
      @cfg << trueBranch =BasicBlock.new
      @cfg << falseBranch=BasicBlock.new
      @cfg << mergeBranch=BasicBlock.new
      @current.to trueBranch
      @current.to falseBranch

      @current=trueBranch
      rec_create_bbs(level+1)
      @current.to mergeBranch

      @current=falseBranch
      rec_create_bbs(level+1)
      @current.to mergeBranch

      @current=mergeBranch
    end

    def gen_while_block level
      @cfg << cond_bb     = BasicBlock.new(:start_while => true)
      cond_bb.infos[:cond]=create_condition
      @cfg << trueBranch  = BasicBlock.new
      @cfg << falseBranch = BasicBlock.new
      @current.to cond_bb
      cond_bb.to trueBranch
      cond_bb.to falseBranch
      @current = trueBranch
      rec_create_bbs(level+1)
      @current.to cond_bb
      @current=falseBranch
    end

    def gen_for_block level
      @cfg << cond_bb     = BasicBlock.new(:start_for => true)
      @index||="idx_0"
      @index=@index.succ
      loop_index=Ident.new Token.create @index
      cond_bb.infos["loop_index"]=loop_index
      @cfg.infos["loop_indexes"]||=[]
      @cfg.infos["loop_indexes"] << loop_index
      cond_bb.infos["loop_index_bound"]=@rng["forloop_iterations"].call.to_i
      @cfg << trueBranch  = BasicBlock.new
      @cfg << falseBranch = BasicBlock.new
      @cfg << postBranch  = BasicBlock.new(:loop_body_end => true)
      @current.to cond_bb
      cond_bb.to trueBranch
      cond_bb.to falseBranch
      @current= trueBranch
      rec_create_bbs(level+1)
      @current.to postBranch
      @current=postBranch
      @current.to cond_bb
      @current=falseBranch
    end

    def populate_all
      puts " |-->[+] populate cfg"
      @cfg.each{|bb| populate bb}
    end

    def populate bb
      @rng["assigns_per_bbs"].call.to_i.times do
        bb << create_assign
      end
    end

    def create_assign
      lhs=create_assignee
      rhs=create_expression()
      Assign.new(lhs,ASSIGN,rhs)
    end

    def create_assignee
      if @params["nb_int_arrays"]>0
        case r=rand(0..10)
        when 0..3
          name,size=@cfg.infos["internal_arrays"].sample.first
          var=@readables.sample
          @readables.rotate!
          abs_func=Ident.new(Token.create "abs")
          return Indexed.new(name,FunCall.new(abs_func,[Binary.new(var,MOD,size)]))
        end
      end
      assignee=@vars.first
      @vars.rotate!
      return assignee
    end

    def create_condition
      lhs=create_expression()
      op =create_cond_op()
      rhs=create_expression()
      Binary.new(lhs,op,rhs)
    end

    def create_expression
      depth=@rng["assigns_expression_depth"].call.to_i
      return create_binary_expression(depth)
    end

    def create_binary_expression depth
      if depth <= 1
        lhs=create_unary_expression
        rhs=create_unary_expression
      else
        lhs=create_binary_expression(depth-1)
        rhs=create_binary_expression(depth-1)
      end
      op=create_binary_op
      if op.val=="/" and lhs.to_s=="0"
        return create_binary_expression(depth)
      else
        return Parenth.new(Binary.new(lhs,op,rhs))
      end
    end

    ARITH={
      :add => "+",
      :sub => "-",
      :mul => "*",
      :div => "/",
      #:shift_r => ">>",
      #:shift_l => "<<",
    }

    COMP={
      :gt  => ">",
      :gte => ">=",
      :lt  => "<",
      :lte => "<=",
      :eq  => "==",
      :neq => "!="

    }

    COMPA=[:gt,:lt,:eq,:neq,:gte,:lte]
    ACCUM=[:add_assign,:sub_assign,:mul_assign,:div_assign]
    LOGIC=[:or,:and,:xor]
    MINUS=Token.new [:sub,"-",[0,0]]

    def create_binary_op
      kind,val=ARITH.sample
      if @params["accept_integer_division"]==false and kind==:div
        return create_binary_op # retry
      end
      Token.new([kind,val,[0,0]])
    end

    def create_cond_op
      kind,val=COMP.sample
      Token.new([kind,val,[0,0]])
    end

    def create_unary_expression
      r=rand(0..10)
      case r
      when 1
        return IntLit.new Token.create rand(0..255).to_s
      when 2
        return Parenth.new(Unary.new(MINUS,@readables.sample))
      when 3
        name,size=@cfg.infos["internal_arrays"].sample.first
        var=@readables.sample
        abs_func=Ident.new(Token.create "abs")
        index=FunCall.new(abs_func,[Binary.new(var,MOD,size)])
        return Indexed.new(name,index) #eg : t[abs(a % 4)]
      else
        return @readables.sample
      end
    end

    def generate_c
      PrinterC.new.print(cfg)
    end
  end
end
