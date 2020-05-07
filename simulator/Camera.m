% Class for a Camera object that observes a scene
classdef Camera < handle
    properties
        Origin
        Rotation
        % Resolution
        ImageWidth
        ImageHeight
        % Min and max depth distances
        MaxDistance
        MinDistance
        % Field of view/Angle of aperture
        FOVWidth
        FOVHeight
        OperatingSpeed
        DepthMatrix
        Points
        DistanceSigma
    end
    methods
        %% Constructor for a Camera
        function camera = Camera(origin, rotation)
            camera.Origin = origin;
            camera.Rotation = rotation;
            
            camera.ImageWidth = 264;
            camera.ImageHeight = 352;
            % Cut resolution in half because too many
            camera.ImageWidth = camera.ImageWidth / 2;
            camera.ImageHeight = camera.ImageHeight / 2;

            camera.MaxDistance = 8000; % in mm
            camera.MinDistance = 300;
            camera.FOVWidth = 60;   % in degrees
            camera.FOVHeight = 45;
            camera.OperatingSpeed = 25;
            camera.DistanceSigma = 0.2;
            camera.DepthMatrix = zeros(camera.ImageHeight, camera.ImageWidth);
            camera.Points = zeros(camera.ImageHeight, camera.ImageWidth, 3);
        end
        
        function fromDistances(cam, distances)
            % Ray represents the direction of the current point
            ray = Ray(cam.Origin, [0 0 0]);

            % Matrix of distances from raw data
            cam.DepthMatrix = reshape(distances, [cam.ImageHeight, cam.ImageWidth]);
            for row = 1:cam.ImageHeight
                % Calculate rowPixel and colPixel, a point in space 2 units away from origin
                rowAngleOffset = row/cam.ImageHeight * cam.FOVHeight - cam.FOVHeight / 2;
                rowPixel = tan(deg2rad(-rowAngleOffset/2));
                for col = 1:cam.ImageWidth
                    colAngleOffset = col/cam.ImageWidth * cam.FOVWidth - cam.FOVWidth / 2;
                    colPixel = tan(deg2rad(-colAngleOffset/2));

                    % Rotate and translate from camera orientation
                    camPixel = cam.Rotation * ([1, rowPixel, colPixel])';
                    camPixel = camPixel' + cam.Origin;

                    % Obtain the direction
                    ray.Direction = (camPixel - cam.Origin) / norm((camPixel - cam.Origin));
                    
                    % Highlight extremities in green
                    if (row == 1 || row == cam.ImageHeight) && (col == 1 || col == cam.ImageWidth)
                        ray.plotObject('g');
                    end
                    
                    % Store point in matrix
                    cam.Points(row, col, :) = ray.Origin + (ray.Direction * cam.DepthMatrix(row, col));
                end
            end

            cam.Points = reshape(cam.Points, [], 3);
        end

        function plotObject(cam)
            for row = [0,cam.ImageHeight]
                rowAngleOffset = row/cam.ImageHeight * cam.FOVHeight - cam.FOVHeight / 2;
                rowPixel = 2 * tan(deg2rad(rowAngleOffset/2));
                for col = [0,cam.ImageWidth]
                    colAngleOffset = col/cam.ImageWidth * cam.FOVWidth - cam.FOVWidth / 2;
                    colPixel = 2 * tan(deg2rad(colAngleOffset/2));
                    camPixel = cam.Rotation * ([1, colPixel, rowPixel])';
                    camPixel = camPixel' + cam.Origin;
                    ray = Ray(cam.Origin, (camPixel - cam.Origin) / norm((camPixel - cam.Origin)));
                    ray.plotObject('g');
                end
            end
        end
        
        % Display camera view into the plot and retrieve all points
        function render(cam, objects)
            % Camera properties
            aspectRatio = cam.ImageWidth / cam.ImageHeight;

            % Calculate scale between pixels
            scaleWidth = tan(deg2rad(cam.FOVWidth * 0.5 ));
            scaleHeight = tan(deg2rad(cam.FOVHeight * 0.5));

            [discard, numobjects] = size(objects);
            
            % Loop through image
            ray = Ray(cam.Origin, cam.Origin);
            for row = 1:cam.ImageHeight
                rowAngleOffset = row/cam.ImageHeight * cam.FOVHeight - cam.FOVHeight / 2;
                rowPixel = 2 * tan(deg2rad(rowAngleOffset/2));
                for col = 1:cam.ImageWidth
                    colAngleOffset = col/cam.ImageWidth * cam.FOVWidth - cam.FOVWidth / 2;
                    colPixel = 2 * tan(deg2rad(colAngleOffset/2));

                    % Translate
                    camPixel = cam.Rotation * ([1, colPixel, rowPixel])';
                    camPixel = camPixel' + cam.Origin;
                    ray.Direction = (camPixel - cam.Origin) / norm((camPixel - cam.Origin));
                    
                    % if (row == 1 || row == cam.ImageHeight) && (col == 1 || col == cam.ImageWidth)
                    %     ray.plotObject('g');
                    % end

                    % Find intersection with all objects
                    leastDistance = cam.MaxDistance + 1;
                    for i = 1:numobjects
                        sceneobj = objects{i};
                        % Maximum two (recorded) hits from any trace. 
                        [hit1, hit2] = sceneobj.intersection(ray);

                        if ~isnan(hit1(1)) && dot(ray.Direction, hit1 - cam.Origin) > 0
                        hitdist = norm(hit1 - cam.Origin);
                            % If the hit is within the viewable distance
                            if hitdist < leastDistance && hitdist < cam.MaxDistance
                                leastDistance = hitdist;
                                cam.Points(row, col, :) = hit1 + ray.Direction * -abs(normrnd(0,cam.DistanceSigma));
                            end
                            % plot3(hit1(1), hit1(2), hit1(3), 'r.', 'MarkerSize', 5, 'LineWidth', 3);
                        end
                        if ~isnan(hit2(1)) && dot(ray.Direction, hit2 - cam.Origin) > 0
                        hitdist = norm(hit2 - cam.Origin);
                            % If the hit is within the viewable distance
                            if hitdist < leastDistance && hitdist < cam.MaxDistance
                                leastDistance = hitdist;
                                cam.Points(row, col, :) = hit2 + ray.Direction * -abs(normrnd(0,cam.DistanceSigma));
                            end
                            % plot3(hit2(1), hit2(2), hit2(3), 'r.', 'MarkerSize', 5, 'LineWidth', 3);
                        end
                    end
                    % Save the closest hit
                    if leastDistance <= cam.MaxDistance
                        cam.DepthMatrix(row, col) = leastDistance;
                    end
                end
            end
            % cam.fromDistances(cam.DepthMatrix);
            cam.Points = reshape(cam.Points, [], 3);
            % Transform the points to camera perspective
            % cam.Points = cam.Points - cam.Origin;
        end
    end
end