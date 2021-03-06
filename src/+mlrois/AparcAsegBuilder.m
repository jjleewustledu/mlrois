classdef AparcAsegBuilder < mlrois.BrainmaskBuilder
	%% APARCASEGBUILDER  

	%  $Revision$
 	%  was created 17-Jan-2018 19:36:36 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlrois/src/+mlrois.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

	methods 
        function this = buildAparcAseg(this, varargin)            
            %% BUILDAPARCASEG uses a pre-existing ct4rb to orthogonally project aparcAseg to the target of ct4rb.
            %  @param named cwd is the current working directory.
            %  @param named tracerIC is an mlfourd.ImagingContext.
            %  @param named t4rb is an mlfourdfp.IT4ResolveBuilder.
            %  @param named ignoreFinishMark is logical; default is false.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'cwd', this.tracerLocation, @isdir);
            addParameter(ip, 't4rb', this.ct4rb_, @(x) isa(x, 'mlfourdfp.IT4ResolveBuilder'));
            parse(ip, varargin{:});
                      
            pwd0 = pushd(ip.Results.cwd);            
            this = this.buildAparcAsegCommon(varargin{:}, 'targetFilename', this.aaFilename);
            this.teardown('sessionData', ip.Results.t4rb.sessionData);            
            popd(pwd0);
        end
        function this = buildAparcAsegBinarized(this, varargin)
            %% BUILDAPARCASEGBINARIZED uses a pre-existing ct4rb to orthogonally project aparcAseg to the target of ct4rb,
            %  then binarize.
            %  @param named cwd is the current working directory.
            %  @param named tracerIC is an mlfourd.ImagingContext.
            %  @param named t4rb is an mlfourdfp.IT4ResolveBuilder.
            %  @param named ignoreFinishMark is logical; default is false.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'cwd', this.tracerLocation, @isdir); 
            addParameter(ip, 't4rb', this.ct4rb_, @(x) isa(x, 'mlfourdfp.IT4ResolveBuilder')); 
            parse(ip, varargin{:});
            
            pwd0 = pushd(ip.Results.cwd);
            this = this.buildAparcAsegCommon(varargin{:}, 'targetFilename', this.aabFilename);
            this.product_ = this.aaBinarized(this.product_, ip.Results);
            this.teardown('sessionData', ip.Results.t4rb.sessionData);            
            popd(pwd0);
        end
        function this = buildAparcAsegCommon(this, varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 't4rb', this.ct4rb_, @(x) isa(x, 'mlfourdfp.IT4ResolveBuilder'));
            addParameter(ip, 'ignoreFinishMark', false, @islogical);
            addParameter(ip, 'targetFilename', @ischar);
            parse(ip, varargin{:});
            
            if (this.aparcAsegMissing) % in cwd
                this.buildVisitor_.convertImageToLocal4dfp( ...
                    this.sessionData.aparcAseg('typ', 'mgz'), 'aparcAseg');
            end            
            if (isempty(ip.Results.t4rb))
                this = this.buildBrainmaskBinarized(varargin{:});
            end            
            if (this.cacheAvailable(ip.Results, ip.Results.targetFilename))
                this.product_ = mlfourd.ImagingContext2(ip.Results.targetFilename);
                return
            end
            this.product_ = this.aaResolved(ip.Results);
        end
		  
 		function this = AparcAsegBuilder(varargin)
 			%% APARCASEGBUILDER
 			%  Usage:  this = AparcAsegBuilder()

 			this = this@mlrois.BrainmaskBuilder(varargin{:});
 		end
 	end 

    %% PRIVATE
    
    methods (Access = private)
        function tf = aparcAsegMissing(this)
            tf = ~lexist(this.aaFilename, 'file');
        end
        function tf = cacheAvailable(~, ipr, fn)
            tf = ~ipr.ignoreFinishMark && lexist(fn, 'file');
        end
        function fn = aaFilename(this)
            fn = this.ensureSafeFileprefix( ...
                 this.sessionData.aparcAseg('typ', '4dfp.hdr'));
        end
        function fn = aabFilename(this)
            fn = this.sessionData.aparcAsegBinarized('typ', '4dfp.hdr');
        end
        function ic = aaResolved(this, ipr)
            t4rb = ipr.t4rb;
            t4 = sprintf('%s_to_%s_t4', this.sessionData.brainmask('typ','fp'), t4rb.resolveTag);
            ic = t4rb.t4img_4dfp(t4, mybasename(this.aaFilename), 'options', '-n'); % target is specified by t4rb
            ic = mlfourd.ImagingContext2([ic '.4dfp.hdr']);
            ic.saveas(['aparcAseg_' t4rb.resolveTag '.4dfp.hdr']);
        end
        function ic = aaBinarized(~, ic, ipr)
            ic = ic.binarized; % set threshold to intensity floor
            ic.saveas(['aparcAsegBinarized_' ipr.t4rb.resolveTag '.4dfp.hdr']);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

