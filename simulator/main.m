clear all; close all; clc;
% set(gcf,'Color','w');
% set(gca, 'FontName', 'Times New Roman');

global showFigures;
showFigures = false;
sliceRange = [0.2 0.3];
% sliceRange = [0 2]; % for real data

% Create ground, slightly slanted down and three rows of cylinders
% Left row is slightly offset to the right
ground = Plane([0 0 0], [0 0.0005 1], 40, 40);

% Base
for iter = [999:1300]
    disp("Generating depth image " + num2str(iter));
    a = deg2rad(3.7 + 90);
    a2 = deg2rad(3.7 + 90);

    farLeftRow  = Cylinder([-10 5 0],  [cosd(a) sind(a) 0], 0.8, 0.8, 15 );
    leftRow     = Cylinder([-5 5 0], [cosd(a) sin(a) 0], 0.8, 0.8, 30);
    centreRow   = Cylinder([0 5 0],  [cos(a) sin(a) 0], 0.8, 0.8, 15);
    rightRow    = Cylinder([5 -10 0],  [cos(a2) sin(a2) 0], 0.8, 0.8, 30);
    farRightRow = Cylinder([10 -10 0],  [cos(a2) sin(a2) 0], 0.8, 0.8, 30);
 
    % Sideways
    % leftRow   = Cylinder([-10.5 -10 0], [0.7 1 0], 0.3, 0.3, 20);
    % centreRow = Cylinder([-8 -10 0],  [0.7 1 0], 0.3, 0.3, 20);
    % rightRow  = Cylinder([-5.5 -10 0],  [0.7 1 0], 0.3, 0.3, 20);

    % Randomiser
    c = clock;
    rng(c(6));

    % Camera faces towards positive y angled down a bit
    thetaX = deg2rad(-10);
    thetaY = deg2rad(0);
    thetaZ = deg2rad(90); % rand(1)*(60) - 30 + 90
    disp("Angle set at: " + num2str(rad2deg(a) - 90) + " camera facing " + num2str(rad2deg(thetaX)) + " " + num2str(rad2deg(thetaY)) + " " + num2str(rad2deg(thetaZ) - 90));
    rotateX = [[1 0 0]; [0 cos(thetaX) -sin(thetaX)]; [0 sin(thetaX) cos(thetaX)]];
    rotateY = [[cos(thetaY) 0 sin(thetaY)]; [0 1 0]; [-sin(thetaY) 0 cos(thetaY)]];
    rotateZ = [[cos(thetaZ) -sin(thetaZ) 0]; [sin(thetaZ) cos(thetaZ) 0]; [0 0 1]];
    % rotateX * rotateY;

    % for camMove = -2:0.1:2
    % disp(strcat("camMove:", num2str(camMove)));
    % cam = Camera([camMove*0.05 -3+camMove 3], rotateX * rotateY * rotateZ);
    cam = Camera([-4 0 3], rotateX * rotateY * rotateZ);
    % cam.Origin = cam.Origin + [0 -5 1];

    % Create figure
    if (showFigures)
        % close all;
        figure(1); clf;
        axis([-5 5 -5 5 -1 10]);
        % axis equal;
        hold on;
        grid on;
    end
    
    objects = {ground, farLeftRow, leftRow, centreRow, rightRow, farRightRow};
    [discard, numobjects] = size(objects);

    if (showFigures)
        for i = 1:numobjects
            sceneobj = objects{i};
            sceneobj.plotObject();
        end
        cam.plotObject();
    end

    drawnow

    tic
    cam.render(objects);
    disp("Ray tracing rendering elapsed time: " + toc + " seconds.");

    if (showFigures)
        xlabel('x');
        ylabel('y');
        zlabel('z');

        figure(2); clf;
        axis([-5 5 -5 5 -1 10]);
        % axis equal;
        hold on; grid on;
        xlabel('x');
        ylabel('y');
        zlabel('z');
        plot3(cam.Points(:,1), cam.Points(:,2), cam.Points(:,3), 'k.');
        cam.plotObject();
    end

    % Store depth into single line text file
    fid = fopen("simulation-dataset/" + num2str(iter) + ".txt", 'w');
    txt = num2str(reshape(floor(cam.DepthMatrix(:)*200), [], 1)');
    txt = regexprep(txt,' +',' '); % replace spaces with one space
    fprintf(fid, '%s', txt);
    fclose(fid);

    % Store data into separate text file
    fid = fopen("simulation-dataset/details.log", 'a');
    % iteration | angle of rows | camera x rotation | camera y rotation | camera z rotation | camera x pos | camera y pos | camera z pos
    txt = num2str(iter) + " " + num2str(-(rad2deg(a) - 90)) + " " + ...
          num2str(rad2deg(thetaX)) + " " + num2str(rad2deg(thetaY)) + " " + num2str(rad2deg(thetaZ) - 90) + " " + ...
          num2str(cam.Origin(1)) + " " + num2str(cam.Origin(2)) + " " + num2str(cam.Origin(3));
    txt = regexprep(txt,' +',' '); % replace spaces with one space
    fprintf(fid, '%s\n', txt);
    fclose(fid);

    tic
    anglesH = performHough(cam.Points, sliceRange, 8);
    disp("Hough elapsed time: " + toc + " seconds.");

    tic
    anglesR = performRANSAC(cam.Points, sliceRange, 3);
    disp("RANSAC elapsed time: " + toc + " seconds.");
    
    % Store collected data into separate text file
    fid = fopen("simulation-dataset/predictions.log", 'a');
    % iteration | type: | predicted angles
    txtReal = num2str(iter) + " Real: " + num2str(-(rad2deg(a) - 90));
    txtH = num2str(iter) + " Hough: " + num2str(anglesH);
    txtR = num2str(iter) + " RANSAC: " + num2str(-anglesR);
    txtReal = regexprep(txtReal,' +',' '); % replace spaces with one space
    txtH = regexprep(txtH,' +',' '); % replace spaces with one space
    txtR = regexprep(txtR,' +',' '); % replace spaces with one space
    fprintf(fid, '%s\n%s\n%s\n', txtReal, txtH, txtR);
    fclose(fid);
    figure;
    
    surf(cam.DepthMatrix);
end