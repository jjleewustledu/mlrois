classdef AbstractRoisBuilder < mlpipeline.AbstractSessionBuilder & mlrois.IRoisBuilder
	%% ABSTRACTROISBUILDER  

	%  $Revision$
 	%  was created 04-Dec-2017 18:06:03 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties
 		
 	end

	methods         
        function [mskt,msktNorm] = msktgenImg(this, varargin)
            %% MSKTGENIMG calls mpr2atl_4dfp and msktgen_4dfp on tracerFn to create quasi-binary masks.
            %  @param optional tracerFn is char; default is this.sessiondata.tracerRevisionSumt.
            %  @returns mskt     is a quasi-binary mask with max ~ 1000 (mlfourd.ImagingContext)
            %  @returns msktNorm is a quasi-binary mask with max = 1    (mlfourd.ImagingContext)            
            
            ip = inputParser;
            addOptional(ip, 'tracerFn', this.sessionData.tracerRevisionSumt('typ', 'fn'), @ischar);
            parse(ip, varargin{:});
            
            pwd0 = pushd(this.tracerLocation);
            
            import mlfourd.*;
            lns_4dfp(ip.Results.tracerFn, this.tracerSafename(ip.Results));
            if (this.existingMskt(ip.Results))
                mskt     = ImagingContext(this.tracerSafenameMskt(ip.Results));
                msktNorm = ImagingContext(this.tracerSafenameMsktNorm(ip.Results));
            else
                [mskt,msktNorm] = this.msktResolved(ip.Results);
            end
            this.teardown;
            
            popd(pwd0);
        end    
        function smpls = sampleRois(this, varargin)
            ip = inputParser;
            addRequired(ip, 'bldr', @(x) isa(x, 'mlpipeline.IDataBuilder'));
            parse(ip, varargin{:});
            
            smpls = repelem(mlfourd.ImagingContext([]), 1, length(this.rois));
            prd = ip.Results.bldr.product;
            for r = 1:length(this.rois)
                prd = prd.masked(this.rois(r));
                prd = prd.volumeContracted(this.rois(r));
                smpls(r) = prd;
            end
        end
        function ic = tracerImg_brain(this, varargin)
            ip = inputParser;
            addParameter(ip, 'tracerIC', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            parse(ip, varargin{:});            
            
            ic = ip.Results.tracerIC;
            if (this.missingTracerImg_brain(ic))
                ic          = mlfourd.ImagingContext(ic.numericalNiftid .* this.msktNN);
                ic.filepath = pwd;
                ic.filename = [ip.Results.tracerIC.fileprefix '_brain.4dfp.ifh'];
                ic.save;
            end
        end
		  
 		function this = AbstractRoisBuilder(varargin)
 			%% ABSTRACTROISBUILDER
            %  @param named 'logger' is an mlpipeline.AbstractLogger.
            %  @param named 'product' is the initial state of the product to build.
            %  @param named 'sessionData' is an mlpipeline.ISessionData.

 			this = this@mlpipeline.AbstractSessionBuilder(varargin{:});
 		end
 	end 
    
    %% PROTECTED
    
    methods (Access = protected)  
        function teardown(~, varargin)
        end   
    end
    
    %% PRIVATE
    
    methods (Access = private)   
        function fn = tracerSafename(~, ipr)
            fn = mybasename(mlfourdfp.FourdfpVisitor.ensureSafeFileprefix(ipr.tracerFn));
        end
        function fn = tracerSafenameMskt(this, ipr)
            fn = [this.tracerSafename(ipr) '_mskt.4dfp.ifh'];
        end
        function fn = tracerSafenameMsktNorm(this, ipr)
            fn = [this.tracerSafename(ipr) '_msktNorm.4dfp.ifh'];
        end
        function tf = existingMskt(this, ipr)
            tf = lexist(this.tracerSafenameMskt(ipr), 'file') && ...
                 lexist(this.tracerSafenameMsktNorm(ipr), 'file');
        end
        function [mskt,msktNorm] = msktResolved(this, ipr)
            st4rb  = mlfourdfp.SimpleT4ResolveBuilder('sessionData', this.sessionData);
            st4rb.msktgenImg(this.tracerSafename(ipr)); % no resolving done, just utility call
            
            import mlfourd.*;
            mskt   = ImagingContext(this.tracerSafenameMskt(ipr));
            msktNN = mskt.numericalNiftid;
            msktNN.img = msktNN.img/msktNN.dipmax;
            msktNN.filename = this.tracerSafenameMsktNorm(ipr);
            msktNN.save;
            msktNorm = ImagingContext(msktNN);
        end
        function tf = missingTracerImg_brain(~, ic)
            tf = ~lexist([ic.fileprefix '_brain.4dfp.ifh'], 'file');
        end
        function nn = msktNN(this)
            [~,mskt] = this.msktgenImg; % ImagingContext
            nn       = mskt.numericalNiftid;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

