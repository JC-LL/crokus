# crokus
C parser written in Ruby, for experimental purpose.

Crokus parses a fair subset of C, using outrageous tricks : many test examples are provided in the tests directory.
Make your own opinion whether Crokus is helpful for you or not (drop me an email !). But don't challenge it too much :-)

Crokus generates an AST (abstract syntax tree), that can be visualized using Graphviz.
Crokus also generates a control-flow graph of each function in the C code.
This CFG can also be viewed using Graphviz, and then viewed in your favorite image format (png, svg etc).

Here is an example of such AST (test_convolution.c)
![AST](/doc/test_convolution.png)

Then, its Control-Flow Graph.
![AST](/doc/cfg_convolve_clean.png)

If you want to implement a transformation, have a look at the Visitor class, for instance used in the PrettyPrinter class.


How to install :
- rely on RubyGems (worldwide repository of Ruby libraries) : "gem install crokus"

How to use :
- on the command line, type "crokus -h". A simple help is provided. Not many options !
- crokus --ast test.c will generate the complete AST for this C file.
- crokus --cfg test.c will generate a CFG for each function enclosed in the C file.
- more to come ! Stay tuned ! 
