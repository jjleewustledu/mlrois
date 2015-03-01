classdef Test_MuellerGartner < MyTestCase
	%% TEST_MUELLERGARTNER 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlrois.Test_MuellerGartner % in . or the matlab path
	%          >> runtests mlrois.Test_MuellerGartner:test_nameoffunc
	%          >> runtests(mlrois.Test_MuellerGartner, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        petobj
        gmobj
        wmobj
        csfobj
        t1msk
 	end

	methods 
 		function test_correctedPet(this) 
 			import mlrois.*; 
            mg = MuellerGartner.correctedPet(this.petobj, this.gmobj, this.wmobj, this.csfobj, this.t1msk);
            mg.gm_soln.save;
            diff = mg.gm_soln - mg.petobj;
            diff = diff.abs;
            diff.fileprefix = [mg.petobj.fileprefix mg.deconvStrategy.suffix '_diffGmSoln'];
            diff.save
 		end 
 		function this = Test_MuellerGartner(varargin) 
 			this = this@MyTestCase(varargin{:}); 
            this.preferredSession = 2;
            % this.petobj = fullfile(this.fslPath, 'cho_f5to24_on_t1_005_gauss3p8391mm_gauss3p8391mm.nii.gz');
            % this.petobj = fullfile(this.fslPath, 'coo_f7to26_on_t1_005_gauss3p8391mm_gauss3p8391mm_gauss3p8391mm.nii.gz');
            this.petobj = fullfile(this.fslPath, 'poc_on_t1_005_gauss3p8391mm_gauss3p8391mm_gauss3p8391mm.nii.gz');
            this.gmobj  = fullfile(this.fslPath, 'gm_on_rawavg.nii.gz');
            this.wmobj  = fullfile(this.fslPath, 'wm_on_rawavg.nii.gz');
            this.csfobj = fullfile(this.fslPath, 'bt1_005_seg_2.nii.gz');
            this.t1msk  = fullfile(this.fslPath, 'bt1_005_mask.nii.gz');
        end % ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

