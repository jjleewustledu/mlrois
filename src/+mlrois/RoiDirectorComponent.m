classdef RoiDirectorComponent  
	%% ROIDIRECTORCOMPONENT   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$  	 

	properties (Abstract)
        roiBuilder
        product
        referenceImage
    end

	methods (Abstract)
        prd = sampleMean(this)
        prd = smapleMedian(this)        
        prd = sampleStd(this)
        prd = sampleCov(this)
        prd = sampleCorrcoef(this)
        prd = sampleKL(this)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

