# XORTRAN

XORTRAN is a multilayer perceptron (MLP) written in FORTRAN IV, compiled and
executed under RT-11 on a PDP-11/34A (via SIMH simulator).

It learns the classic non-linear XOR problem using:

- One hidden layer (4 neurons, leaky ReLU activation)
- Backpropagation with mean squared error loss
- He-like initialization (manual Gaussian via Box-Muller lite)
- Learning rate annealing (0.5 → 0.1 → 0.01)
- Tanh output

The code compiles with the
[DEC FORTRAN IV compiler](https://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/DEC-11-LRFPA-A-D%20RT-11%20FORTRAN%20Compiler%20and%20Object%20Time%20System%20User%27s%20Manual.pdf)
(1974). Execution requires a system with at least 32 kilobytes of memory and an
FP11 floating-point processor. The PDP-11/34A was chosen as it was the smallest
and most affordable PDP-11 equipped with an FP11 floating-point processor in the
1970s.

The training of the 17 parameters should take less than a couple minutes on the
real hardware. In SIMH, setting the throttle to 500K (`set throttle 500K`) will
provide a more realistic execution speed.

### Output

The output shows the mean squared loss every 100 epochs, followed by the final
predictions from the forward pass.

The network converges towards the expected XOR outputs after a few hundred
epochs, gradually reducing the error until it accurately approximates the
desired results.

```
.RUN XORTRN
   1  0.329960233835D+00
 100  0.195189856059D+00
 200  0.816064184115D-01
 300  0.654882376056D-02
 400  0.109833284544D-02
 500  0.928130032748D-03

0 0 GOT:0.008353 EXPECTED:0.
0 1 GOT:0.979327 EXPECTED:1.
1 0 GOT:0.947050 EXPECTED:1.
1 1 GOT:0.020147 EXPECTED:0.
STOP --
```

### How to run

- In SIMH, attach the RL1 drive (`ATT RL1 xortran.rl1`).

- In RT-11 (I use the single job RT-11-SJ V5), assuming `DL1:` is assigned to
  `DK:`:

```text
.FORTRAN/LIST:XORTRN.LST XORTRN.FOR
.LINK XORTRN.OBJ,FORLIB
.RUN XORTRN
```

Or if you just want to run the binary:

```
.RUN DL1:XORTRN
```

## Background

This project demonstrates that a minimal FORTRAN IV environment from the 1970s
was sufficient to implement a basic neural network with backpropagation.\
It’s both a retro-computing curiosity and a small historical experiment bridging
early scientific computing and modern machine learning.

## Licence

© 2025 Damien Boureille

This code is released under the MIT License.\
You are free to use, copy, modify, and redistribute it, provided that you credit
the original author.
