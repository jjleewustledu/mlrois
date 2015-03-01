classdef Test_RoiSamplerBuilder < MyTestCase 
	%% TEST_ROISAMPLERBUILDER
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_RoiSamplerBuilder % in . or the matlab path 
 	%          >> runtests Test_RoiSamplerBuilder:test_nameoffunc 
 	%          >> runtests(Test_RoiSamplerBuilder, Test_Class2, Test_Class3, ...) 
    %  Use cases:
    %  -  ad hoc ROI from any image
    %  -  ad hoc ROI as template
    %  -  template ROI drawn on atlas:   MCA, PCA, cerebellar
 	%  See also:  package xunit%  Version $Revision: 2354 $ was created $Date: 2013-02-01 16:34:34 -0600 (Fri, 01 Feb 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-02-01 16:34:34 -0600 (Fri, 01 Feb 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlrois/test/+mlrois_xunit/trunk/Test_RoiSamplerBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_RoiSamplerBuilder.m 2354 2013-02-01 22:34:34Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant)
        PCA_PETOEF    = -1;
        PCA_THICKNESS = -1;
    end
    
	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        petOef % NIfTI on filesystem
        
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_constructSampler(this) 
 			%% TEST_CONSTRUCTSAMPLER acts as the client to RoiSamplerBuilder
            %  Tests:  RoiSamplerBuilder, RoiSamplerDirector
            
 			import mlfourd.*; 
            builder          = RoiSamplerBuilder;
            director         = RoiSamplerDirector(builder);
            petSampler       = director.constructPetSampler(      'pca'); % director calls its buildPart methods
            thicknessSampler = director.constructThicknessSampler('pca');
            assertElementsAlmostEqual(this.PCA_PETOEF,          petSampler.sample(this.petOef));
            assertElementsAlmostEqual(this.PCA_THICKNESS, thicknessSampler.sample);
 		end % test_pcaSamplerBuilder
        function        setUp(this)
        end
        function        tearDown(this)
        end
 		function this = Test_RoiSamplerBuilder(varargin) 
 			this = this@TestCase(varargin{:});
            
            import mlfourd.*;
            this.petOef = NIfTI.load(fullfile('..', 'data', 'petOef_on_ho'));
 		end % Test_RoiSamplerBuilder (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

