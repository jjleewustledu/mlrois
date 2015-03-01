classdef TissuePriorsRois < mlrois.AbstractRois 
	%% TISSUEPRIORSROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 
    properties (Constant)
        CHANNELS    = { 'csf' 'gray' 'white' 'brain' };
        MASK_SUFFIX = '_mask';
    end
    
    properties        
        atlasFileprefix = 'avg152T1_';
        atlasFolder     = 'tissuepriors';
        maskFileprefix  = '';
    end
    
	properties (Dependent)
        tissuepriorsPath
 	end 

    methods %% SET/GET 
        function pth = get.tissuepriorsPath(this) 
            pth = fullfile(getenv('FSLDIR'), 'data', 'standard', this.atlasFolder, '');
        end
    end
    
	methods 
        function ic = tissuepriorOnSession(this, channel)
            fqfnOnSession = fullfile(this.fslPath, filename([channel this.MASK_SUFFIX]));
            this.roisBuilder.atlas2mask( ...
                this.tissueprior(channel), fqfnOnSession);
            ic = mlfourd.ImagingContext.load(fqfnOnSession);
        end
 		function ic = tissueprior(this, channel) 
            assert(lstrfind(this.CHANNELS, channel));
            ic = mlfourd.ImagingContext.load( ...
                 this.tissuepriorsPath, [this.atlasFileprefix channel '.hdr']);
 		end 
 		function this = TissuePriorsRois(varargin) 
 			%% TISSUEPRIORSROIS 
 			%  Usage:  this = TissuePriorsRois() 

 			this = this@mlrois.AbstractRois(varargin{:}); 
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

