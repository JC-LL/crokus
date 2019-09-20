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


# How to install :
- rely on RubyGems (worldwide repository of Ruby libraries) : "gem install crokus"

# How to use :
- [x] on the command line, type "crokus -h". A simple help is provided. Not many options !
- [x] crokus --ast test.c will generate the complete AST for this C file.
- [x] crokus --cfg test.c will generate a CFG for each function enclosed in the C file.
- [ ] crokus test.c will generate try to generate a three-address code (TAC) textual representation (work in progress !)
- more to come ! Stay tuned !

# How to help :
- report bugs by email or using github. I will try to do my best to fix them.
- suggest or provide enhancements (Ruby code)
- suggest or provide transformations on AST or CFG
- generate code for specific purposes.

#Contact :
- drop me an email at : jean-christophe.le_lann@ensta-bretagne.fr or jc.lelann@gmail.com
