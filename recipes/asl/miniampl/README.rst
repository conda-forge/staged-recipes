========
MiniAMPL
========

A toy AMPL driver to demonstrate usage of the AMPL Solver Library and to get
you going with the writing of your own AMPL driver.

Installing
==========

First install the AMPL Solver Library. We recommend using `Homebrew <http://brew.sh>`_ or `Linuxbrew <http://brew.sh/linuxbrew>`_::

    brew tap homebrew/science
    brew install asl

Next, compile the `miniampl` executable by typing `make`.

Example
=======

Once the `miniampl` executable is created, the following demonstrates how to
call it from the command line. A test example is supplied in `wb.mod` and
`wb.dat`. To generate the test example afresh, execute `ampl wb.ampl`. You can obtain the student edition of AMPL from `www.ampl.com <http://www.ampl.com>`_. But to save you time, I'v also packaged the `nl` file in the `example` folder.

::

    [dpo@pod:miniampl (master)]$ ./bin/miniampl examples/wb    # Only print objective value
    f(x0) = -2.000000000000000e+00

    [dpo@pod:miniampl (master)]$ ./bin/miniampl -=    # Show available options
    showgrad  Evaluate gradient
    showname  Display objective name

    [dpo@pod:miniampl (master)]$ ./bin/miniampl examples/wb showname=1
    showname=1
    Objective name: objective
    f(x0) = -2.000000000000000e+00

    [dpo@pod:miniampl (master)]$ ./bin/miniampl examples/wb showname=1 showgrad=1
    showname=1
    showgrad=1
    Objective name: objective
    f(x0) = -2.000000000000000e+00
    g(x0) = [  1.0e+00  0.0e+00  0.0e+00 ]


What Next?
==========

Writing AMPL drivers is best learned by example. Look through the examples that
come with the AMPL Solver Library and keep `http://www.ampl.com/REFS/HOOKING <http://www.ampl.com/REFS/HOOKING>`_
at hand as a reference.

Good luck.
dominique.orban@gerad.ca


.. image:: https://d2weczhvl823v0.cloudfront.net/dpo/miniampl/trend.png
   :alt: Bitdeli badge
   :target: https://bitdeli.com/free

