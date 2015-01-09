classdef constants
    % constants to use in the bezier package.
    % Author: Adrian V. Dalca, adalca@csail.mit.edu
        
    properties (Constant)
        % constant for now, since only implementation. Everything, including the Static draw()
        % defaults to curves. When/if surfaces (or triangle) will be supported, the Static draw()
        % can still default to curves and drawsurface() could be used for surfaces, or the program
        % can perhaps figure it out from the controlPts.
        type = 'curve';

        % default number of points per voxel to use for nDrawPoints estimate
        pointsPerVoxelDist = 100;
    end
end
