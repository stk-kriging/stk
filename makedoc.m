STK_FOLDER = fileparts( mfilename('fullpath') );
if ~strcmp( STK_FOLDER, pwd() ),
    error('Please run makedoc from the STK folder.');
end

DOC_FOLDER  = fullfile( STK_FOLDER, 'htmldoc' );

HERE = pwd();

addpath(fullfile( STK_FOLDER, 'm2html' ));

% generates documentation
m2html( 'mfiles', {'core' 'covfcs' 'examples' 'sampling' 'utils'}, ...
        'htmlDir', DOC_FOLDER, 'recursive', 'on', ...
        'graph', 'on', 'global', 'on' );
