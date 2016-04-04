function cfg = loaddefault(cfg, defaultCfg)
%LOAD DEFAULT CONFIG
% defaultCfg = struct('a',1,'b',2,'c',3);
% cfg = struct('b',0);
% cfg = loaddefault(cfg, defaultCfg)

%     existingfields = isfield(cfg,fieldnames(defaultCfg));
    
    fields = fieldnames(defaultCfg);
    nfields = numel(fields);
    for n = 1:nfields
        if ~isfield(cfg,fields(n));
            cfg.(fields{n}) = defaultCfg.(fields{n});
        end
    end
end