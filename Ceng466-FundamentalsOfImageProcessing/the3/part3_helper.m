%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}
%{
	INPUT	image		=	image which contains apples
			appleColor	=	color of the apple
							{1: only red apples, 2: only for image C5, 3: both green and red}
%}
function [result] = part3_helper(image, appleColor)

	height = size(image,1);
	width = size(image,2);

	gray_image = rgb2gray(image);
	red_image = image(:,:,1);
	green_image = image(:,:,2);
	blue_image = image(:,:,3);
	hsv_image = rgb2hsv(image);
	kmean_image = segmentation2(image, 3, [0.9; 0.1; 0.5]);
	
	if (appleColor == 1)
		
		green_kmean_image = kmean_image(:,:,2);
		for y=1:height
		    for x=1:width
		        if ((red_image(y,x)< 170 && green_image(y,x)>100) || green_kmean_image(y,x) == 0 || blue_image(y,x) > 150 || (hsv_image(y,x)>0.11 && hsv_image(y,x)<0.16))
		              binary_image(y, x) = 0;
		        else
		            binary_image(y, x) = 1;
		        end
		        if (red_image(y,x) > 240 && blue_image(y,x) > 140 && blue_image(y,x) < 170 && green_image(y,x) < 220)
		        	binary_image(y,x) = 1;
		        end
		    end
		end

		binary_image = bwmorph(binary_image, 'clean');
		binary_image = bwmorph(binary_image, 'spur');
		SE = strel('disk',12);
		binary_image = imclose(binary_image, SE);
		binary_image = bwmorph(binary_image, 'close');
		binary_image = cleanComp(binary_image, uint32(height*width/30));
		w = double(uint32(width/30));
		SE = strel('disk', w);
		binary_image = imclose(binary_image, SE);
		binary_image = bwmorph(binary_image, 'close');
		result = uint8(image).*uint8(binary_image);

	elseif (appleColor == 2)

		binary_image = zeros(height, width, 'logical');
		for y=1:height
		    for x=1:width
		        if ( blue_image(y,x)<55 && blue_image(y,x)>40 && red_image(y,x)<200 && red_image(y,x)>120 && green_image(y,x)<90 && green_image(y,x)>50)
		            binary_image(y, x) = 1;
		        else
		            binary_image(y, x) = 0;
		        end
		    end
		end

		SE = strel('disk',40);
		binary_image = imclose(binary_image, SE);
		[result, n] = bwlabel(binary_image);
		binary_image = cleanComp(binary_image, uint32(height*width/30));
		SE = strel('disk',100);
		result = imclose(result, SE);

		for y=1:height
		    for x=1:width
		        if (result(y,x) > 0)
		            result(y, x) = 1;
		        else
		            result(y, x) = 0;
		        end
		    end
		end

		result = uint8(image).*uint8(result);

	elseif (appleColor == 3)
		binary_image = zeros(height, width, 'logical');
		for y=1:height
		    for x=1:width
		        if (blue_image(y,x)>85 && blue_image(y,x)<135 )
		            binary_image(y, x) = 1;
		        else
		            binary_image(y, x) = 0;
		        end
		    end
		end
		SE = strel('disk',4);
		binary_image = imclose(binary_image, SE);
		SE = strel('disk',45);
		binary_image = imclose(binary_image, SE);

		for y=1:height
		    for x=1:width
		        if (hsv_image(y,x)>0.11 && hsv_image(y,x)<0.16 )
		            binary_image(y, x) = 0;
		        end
		    end
		end

		binary_image = cleanComp(binary_image, uint32(height*width/30));
		SE = strel('disk',8);
		binary_image = imclose(binary_image, SE);

		result = uint8(image).*uint8(binary_image);

	else
		fprintf('Error: The color is not in the range.');
		result = image;
	end
end