classdef RoiDirectorPrevious 
	%% ROIDIRECTOR is a client interface for builders of ROIs
    %
    %  Version $Revision: 2321 $ was created $Date: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/RoiDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: RoiDirector.m 2321 2013-01-21 06:17:57Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Dependent)
        cerebellumMNIflirtAtlas
        cerebellumMNIfnirtAtlas
        harvardOxfordCortAtlas
        harvardOxfordSubAtlas
        juelichMaxprobAtlas
        mniMaxprobAtlas
        talairachAtlas
        brainPrior
        csfPrior
        grayPrior
        whitePrior
        hippocampus
        b0
        brainMaskDeweightEyes
        edges
        eyeMask
        skull
        strucsegPeriph
        ventricleMask
        subbrMask
        brainMask
        mniRois
        morphedRois
    end
    
    methods (Static)    
        function this = createFromModalityPath(pth)
            import mlfourd.*;
            assert(lexist(pth, 'dir'));
            this = RoiDirector.createFromBuilder( ...
                   RoiBuilder.createFromModalityPath(pth));
        end
        function this = createFromBuilder(bldr)
            assert(isa(bldr, 'mlfourd.RoiBuilder'));
            this = mlfourd.RoiDirector(bldr);
        end
        function nz   = nonzeroStats(h, obj)
            obj = double(obj);
            obj = obj(obj ~= 0.0);
            nz  = h(obj);
        end
        function ss   = spanningStats(h, obj)
            obj = double(obj);
            obj = reshape(obj, 1, []);
            ss  = h(obj);
        end
        function es   = exploratoryStats(obj)
            es.mean     = mlfourd.RoiDirector.nonzeroStats(@mean, obj);
            es.median   = mlfourd.RoiDirector.nonzeroStats(@median, obj);
            es.skewness = mlfourd.RoiDirector.nonzeroStats(@skewness, obj);
            es.kurtosis = mlfourd.RoiDirector.nonzeroStats(@kurtosis, obj);
        end
        function plt  = plottedStats(obj)
            plt.histfitted  = mlfourd.RoiDirector.nonzeroStats(@histfit, obj);
            plt.probplotted = mlfourd.RoiDirector.nonzeroStats(@probplot, obj);
            plt.boxplotted  = mlfourd.RoiDirector.nonzeroStats(@boxplot, obj);
        end
    end
    
    methods
        function [this,vals] = exploreImageWithAtlas(this, imobj, atl)
            vals = double(dipmax(atl) - dipmin(atl) + 1, 1);
            for r = dipmin(atl):1:dipmax(atl)
                [this,vals(r)] = this.exploreImageWithAtlasIndex(imobj, atl, r);
            end
        end
        function [this,val]  = exploreImageWithAtlasIndex(this, imobj, atl, idx)
            region = double(atl == idx);
            val = dipsum(region .* imobj)/dipsum(region);
        end
    end

    %% PROTECTED
    
	methods (Access = 'protected')
 		function this = RoiDirectorPrevious(bldr) 
 			%% ROIDIRECTOR 
 			%  Usage:  prefer creation methods
            
            assert(isa(bldr, 'mlfourd.RoiBuilder'));
 		end 
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        mniRois_
        morphedRois_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

