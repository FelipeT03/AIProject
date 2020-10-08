function BW_out = filterRegionsSup(BW_in)
%filterRegions  Filter BW image using auto-generated code from imageRegionAnalyzer app.
%  [BW_OUT,PROPERTIES] = filterRegions(BW_IN) filters binary image BW_IN
%  using auto-generated code from the imageRegionAnalyzer app. BW_OUT has
%  had all of the options and filtering selections that were specified in
%  imageRegionAnalyzer applied to it. The PROPERTIES structure contains the
%  attributes of BW_out that were visible in the app.

% Auto-generated by imageRegionAnalyzer app on 08-Oct-2020
%---------------------------------------------------------

BW_out = BW_in;

% Fill holes in regions.
%BW_out = imfill(BW_out, 'holes');

% Filter image based on image properties.
BW_out = bwpropfilt(BW_out, 'Area', [2000, Inf]);

% Get properties.
properties = regionprops(BW_out, {'Solidity'});

% Sort the properties.
properties = sortProperties(properties, 'Solidity');

BW_out = bwpropfilt(BW_out, 'Solidity', [properties(1).Solidity(1), properties(1).Solidity(1)]);


function properties = sortProperties(properties, sortField)

% Compute the sort order of the structure based on the sort field.
[~,idx] = sort([properties.(sortField)], 'descend');

% Reorder the entire structure.
properties = properties(idx);
