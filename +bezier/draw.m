function [vol, points, t] = draw(controlPts, varargin)
% DRAW draw a bezier curve onto a volume
%	vol = DRAW(controlPts) draw a bezier curve at on a volume. This first inerpolated the curve
%		at several points. The number of such points (nCurvePoints) interpolated is estimated by
%		computing the absolute distance of going through all the points in order, and multiplying
%		that distance by bezier.constants.pointsPerVoxelDist. The volume size is the smallest necessary to
%		encompas the curve.
%
%       Assumes isotropic space elements (e.g. isotropic pixel, voxel).
%
%       controlPts can also be a cell of bezier curves (cell of controlPts), in which case a cell of
%       volumes is returned.
%
%       controlPts is [nControlPts x nDims].
%       vol is the volume (of dimension nDims) in which the curve is drawn
%
%	vol = DRAW(controlPts, volSize) allows for the specification of the volume size. volSize must be
%       [1 x nDims]. If empty array ([]), the smallest volume size will be estimated.
%
%	vol = DRAW(controlPts, volSize, nCurvePoints) allows the specification of the number of
%		points to use for interpolation. nCurvePoints can be specified without volSize by setting
%		volSize to [].
%
%   [vol, points] = DRAW(...) also returns the interpolation points used to draw the curve.
%
%   [vol, points, t] = DRAW(...) also returns the interpolation points' parametrization along the
%       curve.
%
%   Note: the final values of the bezier image are approximated assuming enough nCurvePoints. If
%   something far more precise is needed with a small nCurvePoints, should consider interpolating
%   the given points more carefully.
%
%   Note: current drawing is limited to controlPts specifying points in an actual volume - that is,
%   they have to be > 0, and good drawing will only happen when the volume is large (i.e. not beween
%   1 and 2 or so, but more like 10s or 100s).
%
%   See Also: view, eval
%
%   Author: Adrian V. Dalca, http://adalca.mit.edu
    
    % input checking
    narginchk(1, 3);
    
    % if there are several bezier curves (in cells), return all of them
    if iscell(controlPts)
        vol = cell(numel(controlPts), 1);
        points = cell(numel(controlPts), 1);
        t = cell(numel(controlPts), 1);
        for i = 1:numel(controlPts)
            [vol{i}, points{i}, t{i}] = bezier.draw(controlPts{i}, varargin{:});
        end
        return;
    end
    
    % more input checking
    assert(all(controlPts(:) >= 1), 'All control points must be >= 1 for drawing');
    nDims = size(controlPts, 2);
    
    % get the points
    [points, t] = bezier.eval(controlPts, varargin{2:end});
    
    % get volSize       
    if nargin <= 1 || isempty(varargin{1})
        volSize = ceil(max(points, [], 1));
    else
        volSize = varargin{1};
        assert(all(volSize >= ceil(max(points, [], 1))), 'The specified volSize is too small.');
    end
    
    % transform the coordinates in matlab index by rounding, giving 'votes' for each voxel. 
    % NOTE: round is only useful if curveParamLen is large,
    %   If something far more precise is needed, should consider intrpolating the dimInd values. 
    dimInd = round(points);
    dimIndCell = mat2cell(dimInd, size(dimInd, 1), ones(1, nDims));
    ind = sub2ind(volSize, dimIndCell{:});
    ind = ind(:)';
    
    % count the number of voxes for each index, normalize and create the image 
    indCount = hist(ind, unique(ind));
    vol = zeros(volSize);
    vol(unique(ind)) = indCount;
    vol = vol ./ max(vol(:));
end
