classdef LucyRichardsonDeconvolution < mlrois.DeconvolutionStrategy
	%% LUCYRICHARDSONDECONVOLUTION is the interface to deconvolutions in the strategy design pattern
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
        NUMIT = 5;
        DAMPAR = 0;
        suffix = '_lucy';
    end
    
    properties
        niib
    end
    
	methods 
 		function niib = deconvolve(this, niib, t1msk)  
 			%% DECONVOLVE  
 			%  Usage:   NiiBrowser_obj = obj.deconvolve(NiiBrowser_obj, t1_mask)             
            
            assert(isa(niib, 'mlfourd.NiiBrowser'));
            this.niib = niib;
            niib.img = deconvlucy(niib.img, this.psf, this.NUMIT, []); %%%, this.weight(t1msk));
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
        
 		function this = LucyRichardsonDeconvolution(varargin) 
 			%% WIENER2DECONV 
 			%  Usage:  obj = LucyRichardsonDeconvolution() 
            
 			this = this@mlrois.DeconvolutionStrategy(varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

