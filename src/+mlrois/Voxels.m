classdef Voxels < handle & mlsystem.IHandle
    %% line1
    %  line2
    %  
    %  Created 16-Aug-2023 17:22:30 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlrois/src/+mlrois.
    %  Developed on Matlab 9.14.0.2306882 (R2023a) Update 4 for MACI64.  Copyright 2023 John J. Lee.
    
    properties (Dependent)
        t1w_ic
    end
    
    methods %% GET
        function g = get.t1w_ic(this)
            g = this.bids_med_.t1w_ic;
        end
    end

    methods
        function ic = dlicv_on_target(this, opts)
            arguments
                this mlrois.Voxels
                opts.target mlfourd.ImagingContext2 = this.t1w_ic
            end

            % trivial
            if strcmp(opts.target.fqfn, this.t1w_ic.fqfn)
                ic = copy(this.bids_med_.dlicv_ic_);
                return
            end

            % coregister
            rep = copy(this.representation_);
            rep.coregister(this.t1w_ic, opts.target);
            ic = rep.apply_transform(this.bids_med_.dlicv_ic, interp="nearestneighbour");
        end
        function this = Voxels()
        end
    end

    methods (Static)
        function this = create_for_kinetics(opts)
            arguments
                opts.bids_med mlpipeline.ImagingMediator
                opts.representation = []
            end
            
            this = mlrois.Voxels();
            this.bids_med_ = opts.bids_med;
            this.representation_ = opts.representation;
        end
    end

    %% PROTECTED

    properties (Access = protected)
        bids_med_
        representation_
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
