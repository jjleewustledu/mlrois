classdef AbstractRoisBuilder < mlrois.IRoisBuilder
	%% ABSTRACTROISBUILDER  

	%  $Revision$
 	%  was created 04-Dec-2017 18:06:03 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
        
        function smpls = sampleRois(this, varargin)
            ip = inputParser;
            addRequired(ip, 'bldr', @(x) isa(x, 'mlpipeline.IDataBuilder'));
            parse(ip, varargin{:});
            
            smpls = repelem(mlfourd.ImagingContext([]), 1, length(this.rois));
            prd = ip.Results.bldr.product;
            for r = 1:length(this.rois)
                prd = prd.masked(this.rois(r));
                prd = prd.volumeContracted(this.rois(r));
                smpls(r) = prd;
            end
        end
		  
 		function this = AbstractRoisBuilder(varargin)
 			%% ABSTRACTROISBUILDER
 			%  Usage:  this = AbstractRoisBuilder()

 			this = this@mlrois.IRoisBuilder(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

