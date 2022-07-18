classdef CSIDataFileHandler
    %Class for handling CSI Files using Daniel Halperin CSI Tool
    %Developed by Jesús Albany Armenta García
    %January 20, 2022
    
    properties
       
    end
    
    methods (Static)
        function dataset = getDataset(csiFile, fileType, t, fs, calibrador, featureEx)
            %t = time window length (in seconds) 
            %fs = sample frequeny
            if fileType == 1 %DAT file
                dataMatrix = CSIDataFileHandler.transformFile(csiFile);
            else %a CSI Amp CSV file
                dataMatrix = load(csiFile); 
            end 
            numData = length(dataMatrix); 
            index = 1; 
            for i=1:fs:numData-fs*t
                upperBound = i+t*fs-1;
                if upperBound > numData
                    upperBound = numData; 
                end
                csiWindow = dataMatrix(i:upperBound,:);
                
                calibrador.csiWindow = csiWindow;
                calibratedCSI = calibrador.calibrateCSIWindow();
                featureEx.calibratedCSIWindow = calibratedCSI;
                observation = featureEx.getObservation();
                dataset(index,:) = observation;
                index = index + 1; 
            end
        end
        
        function predictedSet = getPrediction(observationsDataset, classifier)
            %load(model); 
            %classifier = Classifier(model);
            label = zeros(length(observationsDataset),1); 
            for i = 1:length(observationsDataset)
                observation = observationsDataset(i,:); 
                classifier.observation = observation; 
                label(i) = classifier.getModelPrediction(); 
            end
            predictedSet = [observationsDataset label]; 
        end 
        
        function dataMatrix = transformFile(csiFile)
            %fprintf('Processing %d files\n',length(csiFile));
            csi_trace = read_bf_file(csiFile);
            % Extract CSI information for each packet
            %fprintf('File: %s, have CSI for %d packets', csiFile,length(csi_trace))
            % Scaled into linear
            csi = zeros(length(csi_trace),3,30);
            for packet_index = 1:length(csi_trace)
                csi(packet_index,:,:) = get_scaled_csi(csi_trace{packet_index});
            end
            %We are only interested in CSI amplitude
            csiAmpMatrix = permute(db(abs(squeeze(csi))), [2 3 1]); 
            %csi_phase_matrix = permute(angle(squeeze(csi)), [2 3 1]); 
            %Check for inf values
            TF = isinf(csiAmpMatrix); 
            csiAmpMatrix(TF) = NaN;
            csiAmpMatrix = fillmissing(csiAmpMatrix,'movmean',5);
            %TF = isinf(csi_phase_matrix);
            %csi_phase_matrix(TF) = NaN;
            %csi_phase_matrix = fillmissing(csi_phase_matrix,'movmean',5);
%                 for k=1:size(csi_phase_matrix,1)
%                     for j=1:size(csi_phase_matrix,3)
%                         csi_phase_matrix2(k,:,j) = phase_calibration(csi_phase_matrix(k,:,j))';
%                     end
%                 end
            temp = [];
            for packet_index = 1:length(csi_trace)
                temp = [temp;horzcat(reshape(csiAmpMatrix(:,:,packet_index)',[1,90]))];
            end
            dataMatrix = temp;
        end
    end
end

