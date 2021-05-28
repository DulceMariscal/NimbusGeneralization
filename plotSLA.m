close all; clear all; clc;
subID = 'CTR_01';
load([subID 'params'])
scriptDir = fileparts(matlab.desktop.editor.getActiveFilename); 
fh = adaptData.plotAvgTimeCourse(adaptData,'NetContributionNorm2');
saveas(fh, [scriptDir '/SLATimeCourse/' subID '.png'])