function [ m ] = filterString( string_array, keyword )
%FILTERDATASET Find string that contains all the keywords.
%   Detailed explanation goes here

expression = '^';
for i=1:length(keyword)
    word = keyword{i};
    expression = [expression '(?=.*' word ')'];
end
expression = [expression '.+'];

m = regexp(string_array, expression, 'match');

% TODO output idx of matches


