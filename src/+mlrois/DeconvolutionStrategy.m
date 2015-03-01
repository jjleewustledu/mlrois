classdef DeconvolutionStrategy 
	%% DECONVOLUTIONSTRATEGY is the interface to deconvolutions in the strategy design pattern
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Abstract, Constant)
        suffix
    end
    
    methods (Abstract)
        niib = deconvolve(this, niib, t1msk)
    end
    
	methods 
 		function this = DeconvolutionStrategy() 
 			%% DECONVOLUTIONSTRATEGY 
 			%  Usage:  obj = DeconvolutionStrategy() 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

