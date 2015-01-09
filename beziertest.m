function beziertest(testIDs)
% BEZIERTEST testing and examples for bezier curves package
%   BEZIERTEST(testIDs) runs several test or examples for the bezier curves class.
%       current tests:
%       1. display 2D drawing examples with varying nCurvePoints
%       2. see 'error' decreasing for 2D and 3D curves for varying nCurvePoints. 
%               here 'error' is really just the difference (MAD) to the highest nCurvePoints curve
%       3. show several curves in the same 3D plot
%       4. show an example of point interpolation via bezier curve in 2D.
%       5. Interactive drawing.
%
% TODO: more test/examples :)
%
% Author: Adrian V. Dalca, adalca@csail.mit.edu

    % fulls creen figure
    figfun = @() figure('units', 'normalized', 'outerposition', [0 0 1 1]);

    % run all tests, if no test specified
    if nargin == 0
        testIDs = 1:4;
    end

    % display actual images for some 2D examples
    if sum(testIDs == 1) > 0
        
        % test parameters
        nCurves = 5;
        controlPts = [1, 5; 14, 1; 15, 19];
        
        % compute a log scale vector of sample points.
        nCurvePoints = round(logspace(log10(numel(controlPts)), log10(1000), nCurves));

        % go through each case of nCurvePoints, and plot the figures. 
        figfun ();
        d = cell(nCurves, 1);
        for i = 1:numel(nCurvePoints)

            % plot the drawn curve
            subplot(2, nCurves, i);
            d{i} = bezier.view(controlPts, 'nCurvePoints', nCurvePoints(i), 'currentFig', true);
            colorbar;
            title(sprintf('Draw Curve with %d control Pts, %d curve Pts', size(controlPts, 1), ...
                nCurvePoints(i)));

            if i > 1
                % plot the difference to the previous curve
                subplot(2, nCurves, nCurves + i);
                imagesc(abs(d{i} - d{i-1}), [0, 1]);
                bezier.view(controlPts, 'nCurvePoints', nCurvePoints(i), 'currentFig', true, ...
                    'draw', false);
                colorbar;
                title('Difference from previous curve');
            end

        end
    end
    
    
    % more detailed
    if sum(testIDs == 2) > 0
        
        % test parameters
        nTries = 100;
        nCurvePointsMax = 3500;
        controlPts2D = [1, 5; 14, 1; 15, 19];
        controlPts3D = [1, 5, 1; 14, 1, 10; 15, 19, 17];

        % do the sweep in 2D
        [curveParamLen2D, diff2D] = sweepCurveParamLen(controlPts2D, nTries, nCurvePointsMax);
        
        % do the sweep in 3D
        [curveParamLen3D, diff3D] = sweepCurveParamLen(controlPts3D, nTries, nCurvePointsMax);

        % display sweep
        figfun ();

        % display "error" plot for 2D
        subplot(1, 2, 1);
        plot(curveParamLen2D, diff2D, '.-');
        title('2D drawing: MAD from highest curveParamLen');
        ylabel('curveParamLen');
        xlabel('MAD');

        % display "error" plot for 3D
        subplot(1, 2, 2);
        plot(curveParamLen3D, diff3D, '.-');
        title('3D drawing: MAD from highest curveParamLen');
        ylabel('curveParamLen');
        xlabel('MAD');
    end
    
    
    % 3D multiple examples
    if sum(testIDs == 3) > 0
        % parameters
        nCurves = 10;
        
        % build control points for bezier curves
        c = cell(nCurves, 1);
        for i = 1:nCurves; 
            r = [ones(1, 3); randi([1, 10], [3, 3])]; 
            c{i} = cumsum(r, 1); 
        end

        % show the curves
        figfun ();
        bezier.view(c, 'currentFig', true, 'draw', false);
        title(sprintf('%d Bezier curves in 3D', nCurves));
    end

    % see an interpolation example
    if sum(testIDs == 4) > 0
        nPts = 30;
        
        x = linspace(0, 1, nPts);
        y = sin(x .* pi) + randn(1, nPts);
        
        % can't draw since values between 0 and 1.
        figfun ();
        bezier.view([y', x'], 'draw', false, 'currentFig', true);
        title('2D Interpolation with Bezier curves');
    end
    
    % interaction functionality.
    if sum(testIDs == 5) > 0

        % prepare a noisy curve volume to show
        c = [15, 28; 57, 15; 77, 62; 20, 74];
        vol = bezier.view(c, 'volSize', [100, 100]); 
        noisyvol = min(max(vol + randn([100, 100])*0.25, 0), 1);
        
        % show
        close all force;
        h = figure(); 
        imagesc(noisyvol); 
        colormap gray; 
        bezier.explore('currentFig', h);
    end
end


function [nCurvePoints, diff] = sweepCurveParamLen(controlPts, nTries, nCurvePointsMax)
    
    % compute a log scale vector of sample points.
    nCurvePoints = round(logspace(log10(numel(controlPts)), log10(nCurvePointsMax), nTries));
    
    % compute the best volume estimate given the most curve points.
    bestVol = bezier.draw(controlPts, [], nCurvePoints(end));
    
    % compute all volumes and take the differences.
    d = cell(nTries, 1);
    diff = zeros(nTries, 1);
    diff(1) = inf;
    for i = 1:numel(nCurvePoints)
        d{i} = bezier.draw(controlPts, [], nCurvePoints(i));
        locdiff = abs(bestVol - d{i});
        diff(i) = mean(locdiff(:));
    end
end
