# crokus
Crokus is a simple C front-end written in Ruby, for experimental purpose.

Crokus parses a fair subset of C, using outrageous tricks : many test examples are provided in the tests directory.
Make your own opinion whether Crokus is helpful for you or not (drop me an email !).

Crokus generates an AST (abstract syntax tree), that can be visualized using Graphviz.
Crokus also generates a control-flow graph of each function in the C code.
This CFG can also be viewed using Graphviz, and then viewed in your favorite image format (png, svg etc).

Crokus also generates an intermediate format (IR).

Here is an example of such AST (f2.c)
![AST](/doc/f2_ast.png)

Then, its Control-Flow Graph and its textual IR. We are close to assembly !
![AST](/doc/f2_code_cfg_ir.png)

If you want to implement a transformation, have a look at the Visitor class, for instance used in the PrettyPrinter class.

Here how it looks : simply type

 ```bash
   > crokus
   Crokus (0.1.5)- (c) JC Le Lann 2016-20
   Usage: crokus [options]
      -h, --help                       Show help message
      -p, --parse                      parse only
          --pp                         pretty print back source code
          --ast                        abstract syntax tree (AST)
          --cfg                        control-flow graphs for each function
          --tac                        draw three address code (TAC) CFG
          --emit-ir                    dump textual IR from TAC CFG
          --random PARAMS              generates random c files, using parameters
          --trojan FUNC                insert Syracuse Trojan in function FUNC
          --vv                         verbose
      -v, --version                    Show version number
   need a C file : crokus [options] <file.c>
   ```
Let's compile a C file named "f2.c" :
  ```bash
  > crokus f2.c
  Crokus (0.1.5)- (c) JC Le Lann 2016-20
  [+] parsing f2.c
  [+] building CFGs
   |--[+] visitFunction 'f2'
       |--[+] graphviz file saved as 'cfg_f2.dot'
       |--[+] cleaning cfg 'f2'
       |--[+] optimizing cfg 'f2'
       |--[+] cfg size for 'f2' : 11
       |--[+] graphviz file saved as 'cfg_f2_clean.dot'
   |--[+] visitFunction 'main'
       |--[+] graphviz file saved as 'cfg_main.dot'
       |--[+] cleaning cfg 'main'
       |--[+] optimizing cfg 'main'
       |--[+] cfg size for 'main' : 1
       |--[+] graphviz file saved as 'cfg_main_clean.dot'
  [+] pretty_print
   |--[+] saved as f2_pp.c
  [+] building TAC
   |--[+] tac builder for 'f2'
       |--[+] graphviz file saved as 'cfg_tac_f2_clean.dot'
   |--[+] tac builder for 'main'
       |--[+] graphviz file saved as 'cfg_tac_main_clean.dot'
  [+] emit textual IR
   |--[+] IR for 'f2'
       |--[+] generated f2.ir
   |--[+] IR for 'main'
       |--[+] generated main.ir
  ```

## generating random c

Crokus allows to generate random c functions, for experimental purposes. To run, type :

  ```bash
  crokus --random params.yaml
  ```
The yaml files (one is given in tests directory) provides a set of parameters for the random generation, like this (without the '-' in the yaml file ):
- name : "test1"
- nb_inputs: 2
- nb_outputs: 2
- nb_basic_blocks: 50
- nb_int_vars: 10
- nb_int_arrays: 4
- avg_size_int_arrays: 10
- avg_assigns_per_bbs: 2
- avg_assigns_expression_depth: 2
- avg_forloop_iterations: 10
- accept_while_loops: false

Here an exemple of one generated code (content is omitted here but actually present in the basic blocks):
<!-- ![AST](/doc/generated_50.png | width=100) -->
<img src="/doc/generated_50.png" alt="AST" width="500" height="500">

## Trojan insertion
Crokus is also malicious. It is able to insert a specific Trojan (named Syracuse) on a specfic C function. Then the execution may slow down mysteriously. The triggering of Syracuse depends on the combination of specific input values (need documentation).
Syracuse is inserted such that other C compilers cannot remove it through plain dataflow analysis: Syracuse is not dead code.

## How to install :
- rely on RubyGems (worldwide repository of Ruby libraries) : "gem install crokus"

## How to use :
- [x] on the command line, type "crokus -h". A simple help is provided. Not many options !
- [x] crokus --ast test.c will generate the complete AST for this C file.
- [x] crokus --cfg test.c will generate a CFG for each function enclosed in the C file.
- [x] crokus test.c will try to generate a three-address code (TAC) textual representation (work in progress !)
More to come ! Stay tuned !

## How to help :
- report bugs by email or using github. I will try to do my best to fix them.
- suggest or provide enhancements (Ruby code)
- suggest or provide transformations on AST or CFG
- Anyone interested in SSA form ? Help wanted !
- generate code for specific purposes.

## Contact :
- drop me an email at : jean-christophe.le_lann@ensta-bretagne.fr or jc.lelann@gmail.com
