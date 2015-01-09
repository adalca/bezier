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

Getting Started
---------------
Quick evaluation of a 2D bezier curve and plotting:
```
t = bezier.eval([1, 2; 5, 5; 7, 4]);
plot(t(:, 1), t(:, 2));
```
![github:can't display screenshot](/../screenshots/evalsimple.png?raw=true "Simple Plot")

Draw a 2D bezier curve in a volume:
```
vol = bezier.draw([1, 2; 50, 50; 70, 40]);
imagesc(vol); colormap gray;
```
![github:can't display screenshot](/../screenshots/drawsimple.png?raw=true "Simple Plot")

Visualize a 2D curve directly:
```
bezier.view([1, 2; 70, 70; 70, 130]);
```
![github:can't display screenshot](/../screenshots/viewsimple.png?raw=true "Simple Plot")

Visualize a 3D curve directly:
```
bezier.view([1, 2, 7; 5, 5, 9; 9, 9, 9]);
```
![github:can't display screenshot](/../screenshots/view3D.png?raw=true "Simple Plot")

Explore the curves:
```
bezier.explore;
```
![github:can't display screenshot](/../screenshots/exploresimple.png?raw=true "Simple Plot")

To see all of the options for each method, read the documentation and run `beziertest` for more analysis and complete examples.

Contact
-------
[Adrian V. Dalca](http://adalca.mit.edu)
