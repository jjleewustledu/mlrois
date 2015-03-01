classdef Rois < mlrois.AbstractRois
	%% ROIS ...
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	methods 
 		function this = Rois(varargin) 
 			%% ROIS 
 			%  Usage:  obj = Rois() 

            this = this@mlrois.AbstractRois(varargin{:});
 		end %  ctor 
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

