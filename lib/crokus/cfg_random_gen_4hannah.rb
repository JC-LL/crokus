require 'yaml'
require 'distribution'

require_relative 'cfg_printer_c_4hannah'

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
      create_cfg
      gen_dot # to see the structure, before hacking the content
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

    def generate_c
      PrinterC.new.print(cfg)
    end
  end
end
