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
            %  @param required t4rb is an mlfourdfp.IT4ResolveBuilder.
            %  @param optional reuse is logical; default true -> use aparcAsegBinarized_op_tracerRevision.4dfp.ifh.
            %  returns aab, an mlfourd.ImagingContext.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'cwd', this.tracerLocation, @isdir);
            addParameter(ip, 'tracerIC', [], @(x) isa(x, 'mlfourd.ImagingContext')); 
            addParameter(ip, 't4rb', this.ct4rb_, @(x) isa(x, 'mlfourdfp.IT4ResolveBuilder'));
            addParameter(ip, 'ignoreTouchfile', false, @islogical);
            parse(ip, varargin{:});
                      
            pwd0 = pushd(ip.Results.cwd);
            
            if (this.aparcAsegMissing) % in cwd
                this.buildVisitor_.convertImageToLocal4dfp( ...
                    this.sessionData.aparcAseg('typ', 'mgz'), 'aparcAseg');
            end            
            if (isempty(ip.Results.t4rb))
                this = this.buildBrainmaskBinarized(varargin{:});
            end            
            if (this.cacheAvailable(ip.Results, this.aaFilename))
                this.product_ = mlfourd.ImagingContext(this.aaFilename);
                popd(pwd0);
                return
            end
            this.product_ = this.aaResolved(ip.Results);
            this.teardown('sessionData', ip.Results.t4rb.sessionData);            
            popd(pwd0);
        end
        function this = buildAparcAsegBinarized(this, varargin)
            %% BUILDAPARCASEGBINARIZED uses a pre-existing ct4rb to orthogonally project aparcAseg to the target of ct4rb,
            %  then binarize.
            %  @param required t4rb is an mlfourdfp.IT4ResolveBuilder.
            %  @param optional reuse is logical; default true -> use aparcAsegBinarized_op_tracerRevision.4dfp.ifh.
            %  returns aab, an mlfourd.ImagingContext.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'cwd', this.tracerLocation, @isdir);
            addParameter(ip, 'tracerIC', [], @(x) isa(x, 'mlfourd.ImagingContext')); 
            addParameter(ip, 't4rb', this.ct4rb_, @(x) isa(x, 'mlfourdfp.IT4ResolveBuilder'));
            addParameter(ip, 'ignoreTouchfile', false, @islogical);
            parse(ip, varargin{:});
            
            pwd0 = pushd(ip.Results.cwd);
            
            if (this.aparcAsegMissing) % in cwd
                this.buildVisitor_.convertImageToLocal4dfp( ...
                    this.sessionData.aparcAseg('typ', 'mgz'), 'aparcAseg');
            end            
            if (isempty(ip.Results.t4rb))
                this = this.buildBrainmaskBinarized(varargin{:});
            end            
            if (this.cacheAvailable(ip.Results, this.aabFilename))
                this.product_ = mlfourd.ImagingContext(this.aabFilename);
                popd(pwd0);
                return
            end
            this.product_ = this.aaResolved(ip.Results);
            this.product_ = this.aaBinarized(this.product_, ip.Results);
            this.teardown('sessionData', ip.Results.t4rb.sessionData);            
            popd(pwd0);
        end
        function this = buildAparcAsegCommon(this, varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'cwd', this.tracerLocation, @isdir);
            addParameter(ip, 'tracerIC', [], @(x) isa(x, 'mlfourd.ImagingContext')); 
            addParameter(ip, 't4rb', this.ct4rb_, @(x) isa(x, 'mlfourdfp.IT4ResolveBuilder'));
            addParameter(ip, 'ignoreTouchfile', false, @islogical);
            addParameter(ip, 'targetFilename', @ischar);
            parse(ip, varargin{:});
            
            pwd0 = pushd(ip.Results.cwd);
            
            if (this.aparcAsegMissing) % in cwd
                this.buildVisitor_.convertImageToLocal4dfp( ...
                    this.sessionData.aparcAseg('typ', 'mgz'), 'aparcAseg');
            end            
            if (isempty(ip.Results.t4rb))
                this = this.buildBrainmaskBinarized(varargin{:});
            end            
            if (this.cacheAvailable(ip.Results, ip.Results.targetFilename))
                this.product_ = mlfourd.ImagingContext(ip.Results.targetFilename);
                popd(pwd0);
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
            tf = ~ipr.ignoreTouchfile && lexist(fn, 'file');
        end
        function fn = aaFilename(this)
            fn = mlfourdfp.FourdfpVisitor.ensureSafeFileprefix( ...
                this.sessionData.aparcAseg('typ', 'fn.4dfp.ifh'));
        end
        function fn = aabFilename(this)
            fn = this.sessionData.aparcAsegBinarized('typ', 'fn.4dfp.ifh');
        end
        function ic = aaResolved(this, ipr)
            t4rb = ipr.t4rb;
            aa = t4rb.t4img_4dfp_0( ...
                this.sessionData.brainmask('typ','fp'), mybasename(this.aaFilename), 'options', '-n'); % target is specified by t4rb
            aa = mlfourd.ImagingContext([aa '.4dfp.ifh']);
            nn = aa.numericalNiftid;
            nn.saveas(['aparcAseg_' t4rb.resolveTag '.4dfp.ifh']);
            ic = mlfourd.ImagingContext(nn);
        end
        function ic = aaBinarized(~, ic, ipr)
            nn = ic.numericalNiftid;
            nn = nn.binarized; % set threshold to intensity floor
            nn.saveas(['aparcAsegBinarized_' ipr.t4rb.resolveTag '.4dfp.ifh']);
            ic = mlfourd.ImagingContext(nn);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

