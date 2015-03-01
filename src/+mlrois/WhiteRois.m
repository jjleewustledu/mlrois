classdef WhiteRois < mlrois.FastRois  
	%% WHITEROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

    properties        
        maskFileprefix  = 'whiteMask'
    end
    
	methods 
 		 

 		function afun(this) 
 		end 
 		function this = WhiteRois(varargin) 
 			%% WHITEROIS 
 			%  Usage:  this = WhiteRois() 

 			this = this@mlrois.FastRois(varargin{:});  
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

