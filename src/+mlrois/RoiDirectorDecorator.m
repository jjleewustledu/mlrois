classdef RoiDirectorDecorator < mlsurfer.RoiDirectorComponent 
	%% ROIDIRECTORDECORATOR   

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
        function this = set.roiBuilder(this, bldr)
            this.component_.roiBuilder = bldr;
        end
        function bldr = get.roiBuilder(this)
            bldr = this.component_.roiBuilder;
        end
        function this = set.product(this, bldr)
            this.component_.product = bldr;
        end
        function bldr = get.product(this)
            bldr = this.component_.product;
        end
        function this = set.referenceImage(this, bldr)
            this.component_.referenceImage = bldr;
        end
        function bldr = get.referenceImage(this)
            bldr = this.component_.referenceImage;
        end
    end
    
	methods 
 		function [prd,this] = sampleMean(this)
            prd = this.component_.sampleMean;
        end 		
        function [prd,this] = smapleMedian(this)        
            prd = this.component_.sampleMedian;
        end
        function [prd,this] = sampleStd(this)
            prd = this.component_.sampleStd;
        end
        function [prd,this] = sampleCov(this)
            prd = this.component_.sampleCov;
        end
        function [prd,this] = sampleCorrcoef(this)
            prd = this.component_.sampleCorrcoef;
        end
        function [prd,this] = sampleKL(this)
            prd = this.component_.sampleKL;
        end
        function      this  = RoiDirectorDecorator(varargin) 
 			%% ROIDIRECTORDECORATOR 
 			%  Usage:  this = RoiDirectorDecorator() 

 			this = this@mlsurfer.RoiDirectorComponent(varargin{:}); 
 		end 
    end 

    properties (Access = 'protected')
        component_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

