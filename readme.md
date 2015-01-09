Bezier Curves
=============

A package for ND bezier curves operations

A bezier curve is parametrized by controlPts - which is [N x dim] for N control points of
dimension dim. Note that we use matlab matrix ordering, so the first dimension will be
treated as 'y' in the 2D case.

Current function support: 
- `bezier.eval` evaluate the curve at many points
- `bezier.draw` draw the curve in a image or volume
- `bezier.view` visualize 2D or 3D bezier curves (even multiple curves in the same figure)
- `bezier.explore` explore 2D bezier curves interactively

Run `beziertest` for analysis and examples.

Contact
-------
[Adrian V. Dalca](http://adalca.mit.edu)
