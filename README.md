### Analysis Code for

Annie R Bice, Qingli Xiao, Justin Kong, Ping Yan, Zachary Pollack Rosenthal, Andrew W Kraft, Karen P Smith, Tadeusz Wieloch, Jin-Moo Lee, Joseph P Culver, Adam Q Bauer (2022) Homotopic contralesional excitation suppresses spontaneous circuit repair and global network reconnections following ischemic stroke eLife 11:e68852


### Run ProcessQCandXFormOISDat.m
All scripts run on MATLAB 2021a.

Inputs:
- **excelfile**: Database file with list of mice/runs and the associated experiment parameters (see Example.xlsx)
- **rows**: row number(s) within the excel file corresponding to the mice to be analyzed
> Raw data needs to be in .tif format and the dimensions of the data need to be pixels(Y,X) x frames (ex. 128 x 128 x 1000). This processing code is also compatible with binary data.

Outputs:
- **xform_datahb**: contains information on the changes in concentrations of oxygenated and deoxygenated hemoglobin

> *xform_datahb( : , : , 1 , :)* = change in concentration of oxygenated hemoglobin

> *xform_datahb( : , : , 2 , :)* = change in concentration of deoxygenated hemoglobin

