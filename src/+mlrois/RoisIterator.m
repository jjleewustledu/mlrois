classdef RoisIterator < mlpatterns.Iterator
	%% ROISITERATOR  

	%  $Revision$
 	%  was created 14-Jan-2018 19:54:40 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	methods 
        function elts = next(this)
        end
        function tf = hasNext(this)
        end
        function reset(this)
        end
		  
 		function this = RoisIterator(varargin)
 			%% ROISITERATOR
            %  @params required iterable is an mlpatterns.IIterable that instantiated this RoisIterator.
            
            ip = inputParser;
            addRequired(ip, 'iterable', @(x) isa(a, 'mlpatterns.IIterable'));
            parse(ip, varargin{:});
            this.iterable_ = ip.Results.iterable;
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        iterable_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

