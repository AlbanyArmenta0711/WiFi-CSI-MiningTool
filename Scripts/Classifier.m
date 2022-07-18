classdef Classifier < handle
    %Classifier module for breathing and heart rate range/pattern
    %classification
    %Developed by Jesús Albany Armenta García
    %January 19, 2022
    
    properties
        classifierModel
        observation
    end
    
    methods
        function obj = Classifier(classifierModel)
            %Class constructor, model needs to be defined since start
            obj.classifierModel = classifierModel;
        end
        
        function obsLabel = getModelPrediction(obj)
            %Function that return de predicted label for a previous defined
            %observation
            %Model exported from classification learner are contained
            %in structs, therefore classification model needs to selected
            modelCells = struct2cell(obj.classifierModel);
            model = modelCells{1}; 
            modelCells = struct2cell(model);
            %Second cell contains the model 
            model = modelCells{2};
            [obsLabel,~] = predict(model,obj.observation); 
        end
   
    end
end

