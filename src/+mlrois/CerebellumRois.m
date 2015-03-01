classdef CerebellumRois < mlrois.AbstractRois
	%% CEREBELLUMROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 
    properties (Constant)      
        atlasFileprefix = 'Cerebellum-MNIfnirt-prob-2mm'
        atlasFolder     = 'Cerebellum'
        maskFileprefix  = 'cerebellumMask'
    end
    
    methods
 		function this = CerebellumRois(varargin) 
 			%% CEREBELLUMROIS 
 			%  Usage:  this = CerebellumRois
            
            this = this@mlrois.AbstractRois(varargin{:});
 		end 
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

