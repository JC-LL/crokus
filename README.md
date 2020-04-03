# crokus
Crokus is a simple C parser written in Ruby, for experimental purpose.

Crokus parses a fair subset of C, using outrageous tricks : many test examples are provided in the tests directory.
Make your own opinion whether Crokus is helpful for you or not (drop me an email !).

Crokus generates an AST (abstract syntax tree), that can be visualized using Graphviz.
Crokus also generates a control-flow graph of each function in the C code.
This CFG can also be viewed using Graphviz, and then viewed in your favorite image format (png, svg etc).

Here is an example of such AST (test_convolution.c)
![AST](/doc/test_convolution.png)

Then, its Control-Flow Graph.
![AST](/doc/cfg_convolve_clean_50.png)

If you want to implement a transformation, have a look at the Visitor class, for instance used in the PrettyPrinter class.

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

Here an exemple of one generated code :
![AST](/doc/generated_50.png)

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
