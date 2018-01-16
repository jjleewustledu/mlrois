classdef (Abstract) IRoisBuilder 
	%% IROISBUILDER  

	%  $Revision$
 	%  was created 31-May-2017 14:49:57 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties (Abstract)
 		
 	end

	methods (Abstract)
        smpls = sampleRois(this, varargin)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

