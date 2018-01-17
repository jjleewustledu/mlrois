classdef Test_BrainMaskBuilder < matlab.unittest.TestCase
	%% TEST_BRAINMASKBUILDER 

	%  Usage:  >> results = run(mlrois_unittest.Test_BrainMaskBuilder)
 	%          >> result  = run(mlrois_unittest.Test_BrainMaskBuilder, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 14-Jan-2018 23:14:35 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/test/+mlrois_unittest.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        pwd0
 		registry
        sessd
        sessp = '/data/nil-bluearc/raichle/PPGdata/jjlee2/HYGLY28'
 		testObj
 	end

	methods (Test)
		function test_afun(this)
 			import mlrois.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
        end
        function test_view(this)
            this.testObj.product.view;
        end
        function test_brainmaskBinarized(this)
            % See also:  mlpet.TracerDirector.instanceConstructResolvedRois 
            
            [~,ct4rb] = this.testObj.brainmaskBinarized( ...
                'tracerIC', this.sessd.tracerRevisionSumt('typ', 'mlfourd.ImagingContext'));
            aab = this.testObj.aparcAsegBinarized(ct4rb);
            aab.view('fdgv1r1_sumt.4dfp.ifh', 'brainmaskr2_op_fdgv1r1.4dfp.ifh', 'aparcAseg_op_fdgv1r1.4dfp.ifh');
        end
        function test_teardown(this)
            % See also:  mlpet.TracerDirector.instanceConstructResolvedRois            
            
            [~,ct4rb] = this.testObj.brainmaskBinarized( ...
                'tracerIC', this.sessd.tracerRevisionSumt('typ', 'mlfourd.ImagingContext'), 'ignoreTouchfile', true);
            aab = this.testObj.aparcAsegBinarized(ct4rb);
            aab.view('fdgv1r1_sumt.4dfp.ifh', 'brainmaskr2_op_fdgv1r1.4dfp.ifh', 'aparcAseg_op_fdgv1r1.4dfp.ifh');
        end
	end

 	methods (TestClassSetup)
		function setupBrainMaskBuilder(this)
 			import mlrois.*;
            this.sessd = mlraichle.SessionData( ...
                'studyData', mlraichle.StudyData, ...
                'sessionPath', this.sessp, ...
                'vnumber', 1, ...
                'tracer', 'FDG', ...
                'snumber', 1, ...
                'ac', true);
 			this.testObj_ = mlrois.BrainmaskBuilder('sessionData', this.sessd);
 		end
	end

 	methods (TestMethodSetup)
		function setupBrainMaskBuilderTest(this)
 			this.testObj = this.testObj_;
            this.pwd0 = pushd(this.sessp);
 			this.addTeardown(@this.cleanFilesystem);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanFilesystem(this)
            popd(this.pwd0);
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

