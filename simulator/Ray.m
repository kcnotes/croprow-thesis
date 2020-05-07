% Ray class for a vector

classdef Ray
    % Ray in the form Origin + Direction*t
    properties
        Origin
        Direction
    end
    methods
        function ray = Ray(origin, direction)
            ray.Origin = origin;
            ray.Direction = direction;
        end

        function h = plotObject(ray, colour)
            if (colour == 'r' || colour == 'b')
                nextPoint = ray.Origin + ray.Direction * 4;
            else
                nextPoint = ray.Origin + ray.Direction * 10;
            end
            x1 = ray.Origin(1);
            y1 = ray.Origin(2);
            z1 = ray.Origin(3);
            x2 = nextPoint(1);
            y2 = nextPoint(2);
            z2 = nextPoint(3);
            h = plot3([x1 x2], [y1 y2], [z1 z2], strcat(colour, '-'), 'LineWidth', 3);
            hold on;
            % plot3(x1, y1, z1, 'm.');
        end
    end
end