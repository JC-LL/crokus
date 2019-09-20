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
