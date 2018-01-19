classdef WmparcBuilder < mlrois.AparcAsegBuilder
	%% WMPARCBUILDER  

	%  $Revision$
 	%  was created 17-Jan-2018 19:37:30 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
		  
 		function this = WmparcBuilder(varargin)
 			%% WMPARCBUILDER
 			%  Usage:  this = WmparcBuilder()

 			this = this@mlrois.AparcAsegBuilder(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

