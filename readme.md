Bezier Curves
=============

A matlab package for ND bezier curves operations

A bezier curve is parametrized by controlPts - which is [N x dim] for N control points of
dimension dim. Note that we use matlab matrix ordering, so the first dimension will be
treated as 'y' in the 2D case.

Current function support:
- [`bezier.eval`](+bezier/eval.m) evaluate the curve at many points
- [`bezier.draw`](+bezier/draw.m) draw the curve in a image or volume
- [`bezier.view`](+bezier/view.m) visualize 2D or 3D bezier curves (even multiple curves in the same figure)
- [`bezier.explore`](+bezier/explore.m) explore 2D bezier curves interactively

Papers
------
If you find this code useful, please cite:

Dalca, Adrian, et al.  
*Segmentation of nerve bundles and ganglia in spine MRI using particle filters.*  
MICCAI 2011

```
@inproceedings{dalca2011segmentation,
  title={Segmentation of nerve bundles and ganglia in spine MRI using particle filters},
  author={Dalca, Adrian and Danagoulian, Giovanna and Kikinis, Ron and Schmidt, Ehud and Golland, Polina},
  booktitle={International Conference on Medical Image Computing and Computer-Assisted Intervention},
  pages={537--545},
  year={2011},
  organization={Springer}
}
```

Usage
-----
Each method has several helpful options, run `help +bezier` for more help. <br />
Run [`beziertest`](beziertest.m) for thorough examples and to see the extent of possibilities. <br />

### Usage - Quick Start
For quick use try the following:

- plot of a 2D bezier curve:
```
t = bezier.eval([1, 2; 5, 5; 7, 4]);
plot(t(:, 1), t(:, 2));
```
![github:can't display screenshot](/../screenshots/evalsimple.png?raw=true "Simple Plot")

- draw a 2D bezier curve in an image:
```
vol = bezier.draw([1, 2; 50, 50; 70, 40]);
imagesc(vol); colormap gray;
```
![github:can't display screenshot](/../screenshots/drawsimple.png?raw=true "Simple Plot")

- visualize a 2D curve directly:
```
bezier.view([1, 2; 70, 70; 70, 130]);
```
![github:can't display screenshot](/../screenshots/viewsimple.png?raw=true "Simple Plot")

- visualize a 3D curve directly:
```
bezier.view([1, 2, 7; 5, 5, 9; 9, 9, 9]);
```
![github:can't display screenshot](/../screenshots/view3d.png?raw=true "Simple Plot")

- explore the curves:
```
bezier.explore;
```
![github:can't display screenshot](/../screenshots/exploresimple.png?raw=true "Simple Plot")

Contact
-------
[Adrian Dalca](http://adalca.mit.edu)
