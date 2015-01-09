function varargout = view(controlPts, varargin)
% VIEW visualize a bezier curve.
%
%   view(controlPts) visualize a bezier curve defined by the given controlPts. Currently, 2D and 3D
%       visualization is implemented.
%           For 2D: by default, both a image and a plot overlapped with the image will be displayed.
%               The plot will show the curve in blue, along with the control points in red. Note
%               that we use matlab matrix ordering, so the first coordinate is actually y. Also note
%               that when showing an image, the y axes is flipped (as default by matlab)
%           For 3D: by default, if view3d() is available, the curve will be shown in 3D.
%               A 3D plot will then be produced showing the bezier curve in blue, and its control
%               points in red.
%       controlPts can also be a cell array of bezier curves (controlPts). If the cell has more than
%       one element, only the plots will be shown (and not the images).
%   
%   view(controlPts, ParamName, ParamValue, ...) allows for several options in visualizing
%       'draw': logical on whether to also draw the image in a volume (i.e. imagesc or view3D).
%       'volSize': specify the size of the volume if drawing. 
%       'nCurvePoints': specify the number of
%       interpolation curve points.
%       'currentFig': logical on whether to plot/draw in the current figure (default:false);
%
%   [vol, points, t] = view(...) returns the computed volume, points, and t. 
%
%   See Also: draw, eval
%
%   Author: Adrian V. Dalca, http://adalca.mit.edu
    
    % parse inputs
    p = inputParser();
    p.addParamValue('draw', true, @islogical);
    p.addParamValue('volSize', [], @isnumeric);
    p.addParamValue('nCurvePoints', [], @isscalar);
    p.addParamValue('currentFig', false, @isscalar);
    p.parse(varargin{:});

    % treat control points as a cell of control points (bezier curves).
    cellinput = iscell(controlPts); % will use this below as well.
    if ~cellinput
        controlPts = {controlPts};
    end
    nDims = size(controlPts{1}, 2);
    
    % warn if meant to draw, but have more than one curve
    if p.Results.draw && numel(controlPts) > 1
        warning('Skipping draw: Can only draw volume of one bezier curve at a time.');
    end
        
    % compute volumes and points
    showVol = (p.Results.draw && numel(controlPts) == 1);
    if showVol || nargout > 0
        drawVarargin{1} = p.Results.volSize; % volSize can be [], will be handled by draw().
        if ~isempty(p.Results.nCurvePoints)
            drawVarargin{2} = p.Results.nCurvePoints;
            
            % if volSize is not specified and nCurvePoints is, then make sure the volume size
            % includes the control points as well, not just the interpolation points.
            %   this is only reasonable to do for a single bezier curve 
            if numel(controlPts) == 1 && isempty(drawVarargin{1})
                drawVarargin{1} = ceil(max(controlPts{1}, [], 1));
            end
        end
        
        [vol, points, t] = bezier.draw(controlPts, drawVarargin{:});
        varargout = {vol, points, t};
        
    else
        drawVarargin = {};
        if ~isempty(p.Results.nCurvePoints)
            drawVarargin{1} = p.Results.nCurvePoints;
        end
        
        [points, t] = bezier.eval(controlPts, drawVarargin{:});
    end
    
    % display
    switch nDims
        case 2
            
            % default to imagesc.
            if showVol
                imagesc(vol{1});
                colormap gray;
                hold on;
            else
                if ~p.Results.currentFig
                    figure(); 
                end
                hold on;
            end
           
            % draw plots
            for i = 1:numel(controlPts)
                cPts = controlPts{i};
                pts = points{i};
                
                % plot the control points
                plot(cPts(:, 2), cPts(:, 1), 'r--', 'LineWidth', 1);
                plot(cPts(:, 2), cPts(:, 1), 'xr', 'LineWidth', 3, 'MarkerSize', 12);
                
                % plot the curve points
                plot(pts(:, 2), pts(:, 1), 'b', 'LineWidth', 3);
            end
            
        case 3
            if showVol
                % if view3D exists, then show with view3D the actual drawing?
                if exist('view3D', 'file') ~= 2
                    warning('Skipping volume draw: view3D not on matlab path');
                else
                    view3D(vol);
                end
            end
            
            % draw plots
            if ~p.Results.currentFig
                figure(); 
            end
            hold on;
            for i = 1:numel(controlPts)
                cPts = controlPts{i};
                pts = points{i};
                
                % plot the control points
                plot3(cPts(:, 1), cPts(:, 2), cPts(:, 3), 'r--', 'LineWidth', 1);
                plot3(cPts(:, 1), cPts(:, 2), cPts(:, 3), 'xr', 'LineWidth', 3, 'MarkerSize', 12);

                % plot the curve points
                plot3(pts(:, 1), pts(:, 2), pts(:, 3), 'b', 'LineWidth', 3);
                
                % set the view
                view(45, 45);
                
                % grid on
                grid on;
            end
            
        otherwise
            error('%d-volumes not supported for viewing', controlPts.dim);
    end

    
    if nargout > 0 && ~cellinput
        varargout{1} = varargout{1}{1};
        varargout{2} = varargout{2}{1};
        varargout{3} = varargout{3}{1};
    end
end
