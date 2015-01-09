function [points, t] = eval(controlPts, varargin)
% EVAL Evaluate a bezier curve given its control points
%   points = EVAL(controlPts) evaluated (computes coordinates) of the bezier curve at many
%   interpolation points.
%
%   controlPts is [nControlPts x nDims]. The number of points (nCurvePoints) interpolated is
%   estimated by computing the absolute distance of going through all the points in order, and
%   multiplying that distance by bezier.constants.pointsPerVoxelDist. 
%
%   points output is nCurvePoints x nDims
%
%   points = EVAL(controlPts, nCurvePoints) allows the specification of the number of points to use
%   for interpolation.
%
%   points = EVAL(controlPtsCell, ...) allows for a cell of control points (i.e. cell of several
%   bezier curves), which will then return a cell of points.
%
%   [points, t] = EVAL(...) also returns the parametrization of the interpolation points along the
%   curve. t is [nCurvePoints x 1]. If given a cell of control points, t will also be a cell.
%
%   Implementation:
%        currently linear (two CPs), quadratic (three CPs) or cubic (four CPs) bezier curves are
%            directly computed (formulas are evident in the code, in the main switch statement)
% 
%        higher order (more CPs) use a recursive formula.
%           points = repmat(1-t, [1, dim]) .* bezier.eval(controlPts(1:end-1, :), nDrawPoints) + ...
%               repmat(t, [1, dim]) .* bezier.eval(controlPts(2:end, :), nDrawPoints);
%       However, being recursive, this is very computationally costly. Instead, we precompute the
%       matrix: if ptscomp{i,j} gives the points of controlPts i --> j, then we can fill up the
%       matrix by starting with the 4th diagonal (ptscomp{1..,4..}) and then compute each diagonal
%       after that by looking at the entries directly to the right and directly below. The top righ
%       corner, computed last, is our final point array.
% 
%       For large bezier curves, this makes a huge difference:
%           10 CPs:  1.7s --> 0.27s 
%           11 CPs:  3.3s --> 0.32s 
%           15 CPs: 53.1s --> 0.56s
%
%   See Also: draw, view
%
%   Author: Adrian V. Dalca, http://www.mit.edu/~adalca/
   
    narginchk(1, 2);
    
    % if there are several bezier curves (in cells), return all of them
    if iscell(controlPts)
        points = cell(numel(controlPts), 1);
        t = cell(numel(controlPts), 1);
        for i = 1:numel(controlPts)
            [points{i}, t{i}] = bezier.eval(controlPts{i}, varargin{:});
        end
        return;
    end

    % estimate nDrawPoints
    if nargin <= 1
        % this uses the total distance between control points, which is an upper bound on the
        % curve length (I think)
        totalDist = sum(sqrt(ssd(controlPts(2:end, :)', controlPts(1:end-1, :)')));
        totalDist = max(totalDist, 1);
        
        % get about 100 points per voxel.
        nCurvePoints = ceil(totalDist .* bezier.constants.pointsPerVoxelDist);
    else
        nCurvePoints = varargin{1};
    end
    
    % curve parametrization variable
    t = linspace(0, 1, nCurvePoints)';
    
    % detect the type of curve (linear, quadratic, cubic) based on the
    % number of points given in controlPts.
    switch size(controlPts, 1)
        case 1
            error('Number of Control Points should be at least 2');
            
        case 2
            % linear formula
            points = (1 - t) * controlPts(1, :) + ...
                t * controlPts(2, :);
                
        case 3
            % quadratic formula
            points = ((1 - t) .^ 2) * controlPts(1, :) + ...
                (2 * (1 - t) .* t) * controlPts(2, :) + ...
                (t .^ 2) * controlPts(3, :);
                
        case 4
            % cubic formula
            points =  ((1 - t) .^ 3) * controlPts(1, :) + ...
                (3 * (1 - t) .^ 2 .* t) * controlPts(2, :) + ...
                (3 * (1 - t) .* t .^ 2) * controlPts(3, :) + ...
                (t .^ 3) * controlPts(4, :);
                
        otherwise
            % compute using the recursive formula (but avoid recursion)
            [count, dim] = size(controlPts);
            
            % compute 4th diagonal
            ptscomp = cell(count, count);
            for i = 1:(count - 4 + 1)
                ptscomp{i, i+3} = bezier.eval(controlPts(i:i+4-1, :), nCurvePoints);
            end
            
            % compute every diagonal after that 
            for i = 5:count
                for j = 1:(count - i + 1)
                    % use the entry to the left (ptscomp{j, i+j-2}) and below (ptscomp{j+1, i+j-1})
                    ptscomp{j, i+j-1} =  repmat(1 - t, [1, dim]) .* ptscomp{j, i+j-2} + ...
                        repmat(t, [1, dim]) .* ptscomp{j+1, i+j-1};
                        
                    % clean up the entry to the left (this is necessary if we have huge number of control pts)
                    ptscomp{j, i + j - 2} = [];
                end
            end
            
            % finally, get our points:
            points = ptscomp{1, end};
    end
    
    % verify dimensions
    assert(size(points, 2) == size(controlPts, 2));
end

function dst = ssd(v1, v2)
% sum of squared difference

    ds = (v1 - v2) .^ 2;
    dst = sum(ds);
end 
