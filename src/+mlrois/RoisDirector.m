classdef RoisDirector < mlpatterns.Iterator
	%% ROISDIRECTOR  

	%  $Revision$
 	%  was created 17-Jan-2018 18:29:59 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
        function elts = next(this)
        end
        function next = hasNext(this)
        end
        function        reset(this)

        end        
		  
 		function this = RoisDirector(varargin)
 			%% ROISDIRECTOR
            
            ip = inputParser;
            addParameter(ip, 'roisBldr', @(x) isa(x, 'mlrois.IRoisBuilder'));
            parse(ip, varargin{:});
            
            this.roisBuilder_ = ip.Results.roisBldr;
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        roisBuilder_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

