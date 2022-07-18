classdef Calibrator < handle
    %Calibrator class for processing raw CSI data
    %Developed by Jesús Albany Armenta García
    %January 20, 2022
    
    properties
        csiWindow
        bandpassCF1
        bandpassCF2
        bandpassOrder
        bandpassFilter
        aBandpass
        bBandpass
        fs
        polDegree
        sgSize
        hampelSize
        hampelThreshold
        numSubcarriers
        calibratedCSI
        isFirstWindow
        subcarriersIndex
    end
    
    methods
        function obj = Calibrator(bandpassCF1, bandpassCF2, bandpassOrder,...
                  fs, polDegree, sgSize, hampelSize, hampelThreshold,...
                  numSubcarriers)
            %Class constructor
            obj.bandpassCF1 = bandpassCF1; 
            obj.bandpassCF2 = bandpassCF2;
            obj.polDegree = polDegree;
            obj.sgSize = sgSize;
            obj.hampelSize = hampelSize; 
            obj.hampelThreshold = hampelThreshold;
            obj.numSubcarriers = numSubcarriers; 
            obj.bandpassOrder = bandpassOrder;
            obj.fs = fs; 
            obj.isFirstWindow = 1; 
            %Design the bandpass filter 
            obj.bandpassFilter = designfilt('bandpassiir','FilterOrder', bandpassOrder, ...
            'HalfPowerFrequency1',bandpassCF1,'HalfPowerFrequency2',bandpassCF2,  ...
            'SampleRate',fs);
            [obj.bBandpass,obj.aBandpass] = sos2tf(obj.bandpassFilter.Coefficients);
        end
        
        function calibratedCSI = calibrateCSIWindow(obj)
            %calibratedCSI is an struct in which in each field result from
            %each calibration step is stored
            if obj.isFirstWindow == 1
                hampelFiltered = obj.applyHampelFilter(obj.csiWindow);
                sgFiltered = obj.applySGFilter(hampelFiltered);
                bandpassFiltered = obj.applyBandpassFilter(sgFiltered); 
                obj.subcarriersIndex = obj.selectSubcarriers(bandpassFiltered); 
                calibrated = bandpassFiltered(:,obj.subcarriersIndex);
                hampelFiltered = hampelFiltered(:,obj.subcarriersIndex);
                sgFiltered = sgFiltered(:,obj.subcarriersIndex); 
            else
                hampelFiltered = obj.applyHampelFilter(obj.csiWindow(:,obj.subcarriersIndex));
                sgFiltered = obj.applySGFilter(hampelFiltered);
                calibrated= obj.applyBandpassFilter(sgFiltered); 
            end
            field1 = "HampelResult";
            field2 = "SGResult"; 
            field3 = "Result"; 
            value1 = hampelFiltered;
            value2 = sgFiltered;
            value3 = calibrated; 
            calibratedCSI = struct(field1,value1,field2,value2,field3,value3); 
        end
        
        function indexes = selectSubcarriers(obj,data)
            sVar = var(data); 
            [~,indexes] = maxk(sVar,obj.numSubcarriers);
        end 
        
        function hampelFiltered = applyHampelFilter(obj,data)
            hampelFiltered = hampel(data, obj.hampelSize, obj.hampelThreshold); 
        end 
        
        function sgFiltered = applySGFilter(obj,data)
            sgFiltered = sgolayfilt(data,obj.polDegree,obj.sgSize);
        end
        
        function bandpassFiltered = applyBandpassFilter(obj,data)
            bandpassFiltered = filtfilt(obj.bBandpass,obj.aBandpass,data);
        end 
    end
end

