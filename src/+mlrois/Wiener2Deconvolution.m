classdef Wiener2Deconvolution < mlrois.DeconvolutionStrategy
	%% WIENER2DECONV is the interface to deconvolutions in the strategy design pattern
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        FUDGE = 1;
        suffix = '_wiener'
    end
    
    properties
        niib
        t1mask
    end
    
    properties (Dependent)
        noisepower
    end
    
	methods 
 		function [niib, noise] = deconvolve(this, niib, t1msk)  
 			%% DECONVOLVE  
 			%  Usage:   [NiiBrowser_obj, noiee_per_slice] = obj.deconvolve(NiiBrowser_obj)             
            
            assert(isa(niib, 'mlfourd.NiiBrowser'));
            this.niib = niib;
            this.t1mask = t1msk;
            petps = mlpet.PETBuilder.petPointSpread('dispersion', 'sigma');
            pxls = this.FUDGE * ceil(petps ./ niib.mmppix);
            noise = cell(1, size(niib,3));
            for z = 1:size(niib,3)
                [niib.img(:,:,z), noise{z}] = wiener2(niib.img(:,:,z), pxls(1:2));
            end
            niib.fileprefix = [niib.fileprefix this.suffix];
        end 
        function pwr = get.noisepower(this)
            notbrain = ~this.t1mask;
            noiseimg = this.niib .* notbrain;
            meannoise = sum(noiseimg.img(:)) / sum(notbrain.img(:));
            pwr = meannoise * prod(this.niib.size);
        end
        
 		function this = Wiener2Deconvolution(varargin) 
 			%% WIENER2DECONV 
 			%  Usage:  obj = Wiener2Deconv() 

 			this = this@mlrois.DeconvolutionStrategy(varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

