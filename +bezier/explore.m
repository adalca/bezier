function varargout = explore(varargin)
% EXPLORE explore a 2D bezier curve interactively
%   explore() explore a 2D bezier curve interactively by selecting the control points
%       Left mouse click adds a control point, Right click removes the last control point
%
%   explore(ParamName, ParamValue, ...) allows for several options in visualizing
%       'draw': logical on whether to also draw the image in a volume (i.e. imagesc or view3D).
%       'volSize': specify the size of the volume if drawing. Default for explore is [100, 100].
%       'nCurvePoints': specify the number of interpolation curve points.
%       'currentFig': logical on whether to plot/draw in the current figure (default:false);
%
%   controlPts = explore(...) returns the final set of control points
%
%   See Also: view, draw, eval
%
%   Author: Adrian V. Dalca, http://adalca.mit.edu
    
    % parse inputs
    p = inputParser();
    p.addParamValue('draw', [], @islogical);
    p.addParamValue('volSize', [], @isnumeric);
    p.addParamValue('nCurvePoints', [], @isscalar);
    p.addParamValue('currentFig', false, @isscalar);
    p.parse(varargin{:});
    inputs = p.Results;
    viewargins = varargin;


    % prepare title message
    titlemsg = sprintf(['Interactive Bezier Curve Exploration. \n', ...
        'Left Click: add control point. \n Right Click: remove last control point.']);
    
    % prepare drawing options
    if isempty(inputs.draw) && inputs.currentFig > 0
        inputs.draw = false;
        viewargins = [viewargins, 'draw', false];
    else
        inputs.draw = true;
        viewargins = [viewargins, 'draw', true];
    end
    
    % check volume size;
    if isempty(inputs.volSize)
        if inputs.currentFig
            a = get(inputs.currentFig, 'Child');
            xlim = get(a, 'xlim');
            ylim = get(a, 'ylim');
            inputs.volSize = round([ylim(2)-ylim(1), xlim(2) - xlim(1)]);
        else
            inputs.volSize = [100, 100];
        end
    end
    
    % check current figure, and get the image from existing figure if there is one.
    if ~inputs.currentFig
        inputs.currentFig = figure();
        axesh = imagesc(zeros(inputs.volSize));
        bgImg = getimage(axesh);
        viewargins = [viewargins, 'currentFig', inputs.currentFig];
        colormap gray;
        caxis([0, 1]);
        hold on;
    else
        figure(inputs.currentFig);
        bgImg = getimage(gca);
    end
    
    axis([1, inputs.volSize(1), 1, inputs.volSize(2)]);
    title(titlemsg);
    
    % start interactive loop.
    controlPts = [];
    while true
        try
            % get input
            [x, y, button] = ginput(1);
            assert(numel(x) == 1 && x > 0, 'bezier:CleanFigClose', 'unexpected input');
            assert(numel(y) == 1 && y > 1, 'bezier:CleanFigClose', 'unexpected input');
            x = round(x);
            y = round(y);
            
            % if left click, add control point
            if button == 1
                controlPts = [controlPts; y, x]; %#ok<AGROW>
                
            % if right click, erase the last control point
            else 
                assert(button > 2, 'bezier:badInteraction', 'Unrecognized Button');
                if size(controlPts, 1) > 0
                    controlPts(end, :) = [];
                end
            end
            
            % display the control point if only one control point available
            if size(controlPts, 1) == 1
                imagesc(bgImg); 
                hold on;
                plot(controlPts(2), controlPts(1), 'xr', 'LineWidth', 3, 'MarkerSize', 12);
            end
            
            % draw the entire curve otherwise.
            if size(controlPts, 1) > 1
                imagesc(bgImg); 
                hold on;
                bezier.view(controlPts, viewargins{:});
            end
            
            % maintain clean figure
            axis([1, inputs.volSize(1), 1, inputs.volSize(2)]);
            title(titlemsg);
        
        % exit cleanly under some situation
        catch err
            okids = {'MATLAB:ginput:FigureDeletionPause', ...
                'MATLAB:ginput:FigureUnavailable', ...
                'bezier:CleanFigClose'};
            if ~any(strcmp(err.identifier, okids))
                rethrow(err)
            end
            break;
        end
    end

    % prepare output if necessary
    if nargout > 0
        varargout{1} = controlPts;
    end
