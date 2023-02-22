function DetectorAllFiles()
    folder = "./database/";
    files = dir(strcat(folder,'*.mat'));
    for file = files'
       record = strsplit(file.name,'m.mat');
       record = record(1);
       record = strcat(folder, record{1})
       Detector(record); 
    end
end

