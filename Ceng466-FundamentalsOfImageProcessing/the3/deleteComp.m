%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}

%{
	INPUTS	image	= labelled image to delete components
			i 		= index of the component to be deleted
	OUTPUT	result	= image after deleting the component
%}

function [result] = deleteComp(image, i)

height = size(image, 1);
width = size (image, 2);

for x=1:width
    for y=1:height
        if image(y, x) == i
            image(y, x) = 0;
        end
    end
end

result = image;

end