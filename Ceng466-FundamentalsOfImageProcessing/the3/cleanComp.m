%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}
%{
	INPUT	image		=	image which contains apples
			pixelSize	=	range of the pixels
%}
function [result] = cleanComp(image, pixelSize)

	[image, ~] = bwlabel(image);
	[image, n] = bwlabel(image);

	height = size(image, 1);
	width = size (image, 2);

	for i=1:n
		c_size = 0;
		for x=1:width
		    for y=1:height
		        if image(y, x) == i
		        	c_size = c_size + 1;
		        end
		    end
		end

		if (c_size < pixelSize)
			for x=1:width
			    for y=1:height
			        if image(y, x) == i
			        	image(y, x) = 0;
			        end
			    end
			end
		end
	end

	for y=1:height
	    for x=1:width
	        if (image(y,x) > 0)
	            image(y, x) = 1;
	        else
	            image(y, x) = 0;
	        end
	    end
	end

	result = image;
	[image, n] = bwlabel(image);
end
