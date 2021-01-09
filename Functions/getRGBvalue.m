function ptc_rgbValues = getRGBvalue(images_cell, cloudNumber, mergedIndsCell, PV, C, numFrames)

rgbCounter = 1;
for imCounter = 1:1:size(cloudNumber,2)
    if size(mergedIndsCell{1,imCounter},2) > 0
        for indicesCounter = 1:1:size(mergedIndsCell{1,imCounter},2)
            redValue   = 0;
            greenValue = 0;
            blueValue  = 0;
            for viewsCounter = 1:1:numFrames
                index_PV = mergedIndsCell{1, imCounter}(1,indicesCounter);
                index_C = PV(cloudNumber(imCounter)+viewsCounter-1, index_PV); % Consider each of the numFrames views
                image_u_v = C{1,cloudNumber(imCounter)+viewsCounter-1}(:,index_C);
                u = round(image_u_v(1));
                v = round(image_u_v(2));
                redValue   = redValue + double(images_cell{1, cloudNumber(imCounter)+viewsCounter-1}(v, u, 1));
                greenValue = greenValue + double(images_cell{1, cloudNumber(imCounter)+viewsCounter-1}(v, u, 2));
                blueValue  = blueValue + double(images_cell{1, cloudNumber(imCounter)+viewsCounter-1}(v, u, 3));
            end
            ptc_rgbValues(:,rgbCounter) = [redValue/numFrames; greenValue/numFrames; blueValue/numFrames]; % take average of RGB values
            rgbCounter = rgbCounter + 1;
        end
    end
end

end