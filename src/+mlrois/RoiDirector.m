classdef RoiDirector < mlsurfer.RoiDirectorComponent 
	%% ROIDIRECTOR   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties (Dependent)
 		 roiBuilder
         product
         referenceImage
    end 
    
    methods %% SET/GET
    end

	methods         
        function [prd,this] = sampleMean(this)
        end
        function [prd,this] = smapleMedian(this)        
        end
        function [prd,this] = sampleStd(this)
        end
        function [prd,this] = sampleCov(this)
        end
        function [prd,this] = sampleCorrcoef(this)
        end
        function [prd,this] = sampleKL(this)
        end
        function      this  = RoiDirector(varargin)
            this = this@mlsurfer.RoiDirectorComponent(varargin{:});
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

