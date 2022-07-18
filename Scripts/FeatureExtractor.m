classdef FeatureExtractor < handle
    %Class for extracting time and frequency domain features
    %Developed by Jesús Albany Armenta García
    %January 20, 2022
    
    properties
        calibratedCSIWindow
        timeDomainFeatures
        frequencyDomainFeatures
        sampleFrequency
        lastF
        lfSize
        lfIndex
        lastEstimations
    end
    
    methods
        function obj = FeatureExtractor(sampleFrequency)
            %Class constructor
            obj.sampleFrequency = sampleFrequency; 
            obj.lfSize = 3; %number of frequencies to be averaged for a new estimation
            obj.lfIndex = 1; 
            obj.lastF = NaN; 
        end
        
        function obj = setCSIWindow(obj,csiData)
            %csiData is normalized
            csiData = normalize(csiData,'range',[-1 1]);
            obj.calibratedCSIWindow = csiData; 
        end
        
        function [observation] = getObservation(obj)
            tdf = obj.getTimeDomainFeatures(); 
            fdf = obj.getFreqDomainFeatures();
            observation = [tdf fdf];  
        end
        
        function tdf = getTimeDomainFeatures(obj)
            meanSC = mean(obj.calibratedCSIWindow.Result); 
            varSC = var(obj.calibratedCSIWindow.Result); 
            skwSC = skewness(obj.calibratedCSIWindow.Result); 
            kurtSC = kurtosis(obj.calibratedCSIWindow.Result); 
            %obtain TDF from approximation and detailed coefficients
            %from DWT
            [~,numSC] = size(obj.calibratedCSIWindow.Result);
            CD1Var = zeros(1,numSC);
            CD2Var = zeros(1,numSC);
            CD3Var = zeros(1,numSC);
            CD4Var = zeros(1,numSC);
            CD1Mean = zeros(1,numSC);
            CD2Mean = zeros(1,numSC);
            CD3Mean = zeros(1,numSC);
            CD4Mean = zeros(1,numSC);
            ApproxVar = zeros(1,numSC);
            ApproxMean = zeros(1,numSC);
            for currentsc=1:numSC
                [c,l] = wavedec(obj.calibratedCSIWindow.HampelResult(:,currentsc),4,'db2');
                approx = appcoef(c,l,'db2');
                [cd1,cd2,cd3,cd4] = detcoef(c,l,[1 2 3 4]);
                %Normalize each coefficients between 0 and 1 
                cd1Norm = normalize(cd1,'range',[0 1]);
                cd2Norm = normalize(cd2,'range',[0 1]);
                cd3Norm = normalize(cd3,'range',[0 1]);
                cd4Norm = normalize(cd4,'range',[0 1]);
                approxNorm = normalize(approx,'range',[0 1]);            
                CD1Var(currentsc) = std(cd1Norm);          
                CD2Var(currentsc) = std(cd2Norm);           
                CD3Var(currentsc) = std(cd3Norm);           
                CD4Var(currentsc) = std(cd4Norm);            
                CD1Mean(currentsc) = mean(cd1Norm);          
                CD2Mean(currentsc) = mean(cd2Norm);           
                CD3Mean(currentsc) = mean(cd3Norm);           
                CD4Mean(currentsc) = mean(cd4Norm);  
                ApproxVar(currentsc) = var(approxNorm);
                ApproxMean(currentsc) = mean(approxNorm);
            end
            
            build tdf
            tdf = [CD1Var CD2Var CD3Var CD4Var CD1Mean CD2Mean CD3Mean...
               CD4Mean ApproxMean ApproxVar meanSC varSC kurtSC...
               skwSC];
            
        end 
        
        function fdf = getFreqDomainFeatures(obj)
            %First frequency spectrum must be obtained by using FFT
            n = 2^nextpow2(length(obj.calibratedCSIWindow.Result));
            X = fft(obj.calibratedCSIWindow.Result,n);
            X = X./max(X);
            X = fftshift(X);
            psd = abs(X);
            kk = 0:n-1;
            F = kk/n*obj.sampleFrequency-obj.sampleFrequency/2;
            [~,index] = find(F==0);
            F = F(index:n);
            psd = psd(index:n,:);
            meanPSD = zeros(length(psd),1); 
            for j=1:length(psd)
                meanPSD(j) = mean(psd(j,:)); 
            end
            [~,indexMaxFrequency] = max(meanPSD);
            frequency = F(indexMaxFrequency); 
            if isnan(obj.lastF) %if first estimation...
                obj.lastF = frequency; %Max frequency in power spectrum
                nearestF = obj.lastF;   
                obj.lastEstimations(1) = obj.lastF; 
                obj.lfIndex = obj.lfIndex + 1; 
            else
                if obj.lfIndex < obj.lfSize
                    obj.lastEstimations(obj.lfIndex) = (sum(obj.lastEstimations) + ...
                        frequency)/(numel(obj.lastEstimations)+1); 
                    nearestF = obj.lastEstimations(obj.lfIndex);
                    obj.lfIndex = obj.lfIndex + 1; 
                else                           
                    obj.lfIndex = 1; 
                    obj.lastEstimations(obj.lfIndex) = (sum(obj.lastEstimations) + ...
                        frequency)/obj.lfSize;
                    nearestF = obj.lastEstimations(obj.lfIndex);
                end
            end 
            %First estimation done based on frequency spectrum (for
            %breathing and heart rate
            firstEstimation = round(60*nearestF);
            [~,maxPos] = max(psd);    
            maxFreq = F(maxPos);
            spectrumSTD = std(psd); 
            fdf = [maxFreq spectrumSTD firstEstimation]; 
        end 
        
    end
end

