classdef ThalamusRois < mlrois.AbstractRois  
	%% THALAMUSROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties 
 		 
 	end 

	methods 
 		 

 		function afun(this) 
 		end 
 		function this = ThalamusRois(varargin) 
 			%% THALAMUSROIS 
 			%  Usage:  this = ThalamusRois() 

 			this = this@mlrois.AbstractRois(varargin{:});  
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

