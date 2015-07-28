function val_input =  validateDTWMDSinputContent
    
    val_input = struct('sequence', [], ... % sequence, matrix format 
                       'temporalIdx', 1, ... % temporal index in the ts
                       'instanceIdx', 1);  % instance index of ts 
	return;

end