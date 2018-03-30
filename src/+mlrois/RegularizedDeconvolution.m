classdef RegularizedDeconvolution < mlrois.DeconvolutionStrategy
	%% REGULARIZEDDECONVOLUTION is the interface to deconvolutions in the strategy design pattern
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        FUDGE = 2;
        suffix = '_regular'
    end
    
    properties
        niib
        t1mask
        bkrnd
    end
    
    properties (Dependent)
        noisepower
        lrange
    end
    
	methods 
        function pwr = get.noisepower(this)
            notbrain = this.t1mask.ones - this.t1mask;
            noiseimg = this.bkrnd .* notbrain;
            sqrnoise = noiseimg.img.^2;
            rmsnoise = sqrt(sum(sqrnoise(:)) / sum(notbrain.img(:)));
            pwr = rmsnoise * prod(this.niib.size);
            pwr = double(pwr); % bug in Matlab's deconvreg
        end
        function rng = get.lrange(this)
            absniib = this.niib.abs;
            rng = [absniib.dipmin absniib.dipmax];
            if (~isfinite(rng))
                rng = [1e-9 1e9]; end
            
            rng = double(rng); % bug in Matlab's deconvreg
        end
        
 		function [niib, lagra] = deconvolve(this, niib, t1msk, bkrnd)  
 			%% DECONVOLVE  
 			%  Usage:   [NiiBrowser_object, lagrange_multiplier] = obj.deconvolve(NiiBrowser_object)             
            
            assert(isa(niib, 'mlfourd.NiiBrowser'));
            this.niib = niib;
            this.t1mask = t1msk;
            if (~exist('bkrnd','var'))
                bkrnd = this.niib; end
            this.bkrnd = bkrnd;
            [niib.img, lagra] = deconvreg(niib.img, this.psf, this.noisepower, this.lrange); 
            niib.fileprefix = [niib.fileprefix this.suffix];
        end 
        function inplane = psf(this)
            petps = mlpet.PETBuilder.petPointSpread('dispersion', 'sigma');
            pxls = this.FUDGE * ceil(petps ./ this.niib.mmppix);
            inplane = fspecial('gaussian', pxls(1:2), petps(1));
        end
        function msk = weight(~, msk)
            imcast(msk, 'double');
            msk = double(msk > 0);
        end
        
 		function this = RegularizedDeconvolution(varargin) 
 			%% WIENER2DECONV 
 			%  Usage:  obj = LucyRichardsonDeconvolution() 
            
 			this = this@mlrois.DeconvolutionStrategy(varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

