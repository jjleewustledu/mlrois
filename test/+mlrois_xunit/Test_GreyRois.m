classdef Test_GreyRois < MyTestCase 
	%% TEST_GREYROIS  

	%  Usage:  >> runtests tests_dir  
	%          >> runtests mlrois.Test_GreyRois % in . or the matlab path 
	%          >> runtests mlrois.Test_GreyRois:test_nameoffunc 
	%          >> runtests(mlrois.Test_GreyRois, Test_Class2, Test_Class3, ...) 
	%  See also:  package xunit 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties 
 		 
 	end 

	methods 
 		 
        function test_greyMask(this)
        end
 		function test_greySessionPrior(this) 
 			import mlrois.*; 
        end 
        
 		function this = Test_GreyRois(varargin) 
 			this = this@MyTestCase(varargin{:}); 
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

