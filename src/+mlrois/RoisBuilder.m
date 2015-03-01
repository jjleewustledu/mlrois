classdef RoisBuilder < mlmr.MRAlignmentBuilder 
	%% ROISBUILDER   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties
 	end 

    methods (Static)
        function msk = normalizeMask(msk)
            nii = msk.nifti;
            nii.img = nii.img / nii.dipmax;
            nii.save;
        end
        function msk = intersectMasks(varargin)
            cellfun(@(v) assert(isa(v, 'mlfourd.ImagingContext')), varargin);
            
            import mlrois.*;
            msk = RoisBuilder.normalizeMask(varargin{1});
            for v = 2:length(varargin)
                msk = msk .* RoisBuilder.normalizeMask(varargin{v});                
            end
        end
        function msk = unionMasks(varargin)
            cellfun(@(v) assert(isa(v, 'mlfourd.ImagingContext')), varargin);
            
            import mlrois.*;
            msk = RoisBuilder.normalizeMask(varargin{1});
            for v = 2:length(varargin)
                msk0 = msk;
                msk1 = RoisBuilder.normalizeMask(varargin{v});
                msk  = msk0 + msk1 - RoisBuilder.intersectMasks(msk0, msk1);
            end
        end
    end
    
	methods
        function        atlas2mask(this, atlas, mask)
            atlas = imcast(atlas, 'mlfourd.ImagingContext');
            mask  = imcast(mask,  'mlfourd.ImagingContext');
            this.product = atlas;
            vtor = mlfsl.FnirtVisitor;
            this = vtor.visitRoisBuilder2applywarp(this);
            if (lstrfind(this.product.fqfilename, this.fslPath))
                mlbash(sprintf('mv -f %s %s', this.product.fqfilename, mask.fqfilename)); end
            this.normalizeMask(mask);
        end
        
 		function this = RoisBuilder(varargin) 
 			%% ROISBUILDER 
 			%  Usage:  this = RoisBuilder([...]) 
            %                              ^ cf. mlmr.MRAlignmentBuilder
            
 			this = this@mlmr.MRAlignmentBuilder(varargin{:}); 
 		end 
    end 
    
    %% PRIVATE
    

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

