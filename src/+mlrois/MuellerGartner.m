classdef MuellerGartner
	%% MUELLERGARTNER implements J Cereb Blood Flow Metab 1992; 12(4):571--583
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        cutoff = 0.05;
    end
    
	properties
        petobj
        t1msk
        gm_X
        wm_X
        csf_X
        gm_soln
        wm_bar
        csf_bar
        deconvStrategy
        noise
    end

    methods (Static)
        function this = correctedPet(petobj, gmobj, wmobj, csfobj, t1msk, deconv)
            %% CORRECTEDPET is the principal function for the class; co-registration required;
            %  Blurring by pet point-spread function is performed internally.
            %  Usage:   MuellerGartner.correctPartialVolumes(pet_objec, grey_matter_mask, white_matter_mask)

            import mlrois.*;
            if (~exist('deconv', 'var'))
                deconv = 'regular'; end
            this = MuellerGartner(petobj, gmobj, wmobj, csfobj, t1msk, deconv);
            [tmp,this]  = this.tracer_conc(this.wm_X  .* this.petobj, this.t1msk);
            this.wm_bar = tmp;
            [tmp,this] = this.tracer_conc(this.csf_X .* this.petobj, this.t1msk);
            this.csf_bar = tmp;
            
            this.gm_soln = this.petobj - ...
                MuellerGartner.h(this.wm_bar .* this.wm_X) - MuellerGartner.h(this.csf_bar .* this.csf_X);
            this.gm_soln = this.gm_soln ./ MuellerGartner.h(this.gm_X);
            this.gm_soln.fileprefix = [this.petobj.fileprefix this.deconvStrategy.suffix '_gmsoln'];
        end
        function imobj = h(imobj)
            %% H convolves with the PET point-spread function from PETBuilder
            imobj = imcast(imobj, 'mlfourd.NiiBrowser');
            fp0   = imobj.fileprefix;
            imobj = imobj.blurredBrowser;
            imobj.fileprefix = [fp0 '_petps'];
        end
        function [X1,X2,X3] = mutuallyExclude(msk1, msk2, msk3)
            %% MUTUALLYEXCLUDE makes masks mutually exclusive, or 1-to-1-onto;
            %  internally converts to NiiBrowser.
            %  Usage:  [exclusive1,exclusive2,exclusive3] = mutuallyExclude(mask1, mask2, mask3)
            
            msk1 = imcast(msk1, 'mlfourd.NiiBrowser');
            msk2 = imcast(msk2, 'mlfourd.NiiBrowser');
            msk3 = imcast(msk3, 'mlfourd.NiiBrowser');
            X3   = tidy( msk3 - (msk3 .* msk1) - (msk3 .* msk2) );
            X2   = tidy( msk2 + (msk2 .* X3) );
            X1   = tidy( msk1 + (msk1 .* X2) + (msk1 .* X3) );
            
            function x = tidy(x)
                x.img = x.img > 0;
                x.fileprefix = [x.fileprefix '_1to1onto'];
            end
        end
    end

    methods
        function [niib,this] = tracer_conc(this, petraw, tissmsk)
            %% TRACER_CONC gives the best estimate from 2-D Wiener filtering
            %  [niib, noise] = tracer_conc(raw_pet)
            %                              ^ filename, NIfTI, numeric, ...
            %  See also:   wiener2, imcast
            
            niib = imcast(petraw, 'mlfourd.NiiBrowser');
            nois = cell2mat(this.noise);
            if (isa(this.deconvStrategy, 'mlrois.Wiener2Deconvolution'))
                [niib, this.noise] = this.deconvStrategy.deconvolve(niib, tissmsk);
                fprintf('\nNoise power estimated by Wiener2Deconovlution:\n');                
                fprintf('\tsize:  %i', size(nois));
                fprintf('\tmean:  %f', mean(nois(:)));
                fprintf('\tstd:  %f', std(nois(:)));
                return
            end
            if (isa(this.deconvStrategy, 'mlrois.RegularizedDeconvolution'))                
                niib = this.deconvStrategy.deconvolve(niib, tissmsk, this.petobj);
                return
            end
            niib = this.deconvStrategy.deconvolve(niib, tissmsk);
        end
        function this = setDeconvStrategy(this, choice)
            switch (lower(choice))
                case 'wiener2' 
                    this.deconvStrategy = mlrois.Wiener2Deconvolution;
                case 'lucy'
                    this.deconvStrategy = mlrois.LucyRichardsonDeconvolution;
                case 'regular'
                    this.deconvStrategy = mlrois.RegularizedDeconvolution;
                otherwise
                    error('mlrois:unsupportedParameterValue', 'MuellerGartner.setDeconvStrategy.choice -> %s', choice);
            end
            assert(~isempty(this.deconvStrategy));
        end
    end
    
    methods (Access = 'private')
 		function this = MuellerGartner(petobj, gmobj, wmobj, csfobj, t1msk, deconv) 
            %% MUELLERGARTNER requires advanced co-registration.  Do not blur inputs.
            %  Blurring by pet point-spread function is performed internally.
            %  Usage:   this = MuellerGartner(pet_objec, grey_matter_mask, white_matter_mask)
            
            this.petobj    = imcast(petobj, 'mlfourd.NiiBrowser');
            this.gm_X      = imcast(gmobj,  'mlfourd.NiiBrowser');
            this.wm_X      = imcast(wmobj,  'mlfourd.NiiBrowser');
            this.csf_X     = imcast(csfobj, 'mlfourd.NiiBrowser');
            this.t1msk     = imcast(t1msk,  'mlfourd.NiiBrowser');

            this.gm_X.img  = abs(this.gm_X.img)  > this.gm_X.dipmean  * this.cutoff;
            this.wm_X.img  = abs(this.wm_X.img)  > this.wm_X.dipmean  * this.cutoff;
            this.csf_X.img = abs(this.csf_X.img) > this.csf_X.dipmean * this.cutoff;

            assert(all(this.petobj.size == this.gm_X.size));
            assert(all(this.petobj.size == this.wm_X.size));
            assert(all(this.petobj.size == this.csf_X.size));
            assert(all(this.petobj.size == this.t1msk.size));
            assert(0 == this.petobj.blurCount);
            assert(0 == this.gm_X.blurCount);
            assert(0 == this.wm_X.blurCount);            
            assert(0 == this.csf_X.blurCount);         
            assert(0 == this.t1msk.blurCount);               
            assert(0 == this.t1msk.dipmin);
            assert(1 == this.t1msk.dipmax);
            
            this = this.setDeconvStrategy(deconv);

            [this.gm_X,this.csf_X,this.wm_X] = mlrois.MuellerGartner.mutuallyExclude(this.gm_X, this.csf_X, this.wm_X);
            this.gm_X = this.gm_X .* this.t1msk;
            this.wm_X = this.wm_X .* this.t1msk;
            this.csf_X = this.csf_X .* this.t1msk;           
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

