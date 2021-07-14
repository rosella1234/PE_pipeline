# PE_pipeline
Matlab-based image processing pipeline in support of diagnosis of Pectus Excavatum (PE) patients. Our pipeline allows automatic computation of existing clinical indexes used in PE diagnosis and tratment with unprecedented advantages of avoiding user bias and saving time. Moreover, extraction of new volumetric marker reflecting pathologic severity is proposed.

## Dependencies:
The software code has been developed in MATLAB® 2020a, running in Windows 10.
## Data structure:
```
Anonymized - patient_id
  |- BTFE_BH
      |- dcm files
      |- results
        |- indexes.xlsx
 ```
               
 ## How to run:
`main` function contains calls for all submodules explained in detail below. 
Current framework is organized in four interconnected modules summarized below: Pre-processing, Depression quantification, Inner chest contour segmentation and Thoracic indexes computation. 
![image](https://user-images.githubusercontent.com/58302565/125595264-331b32ee-87ce-4d07-9d46-761cdf072b14.png)

## Pre-processing:
As a preliminary step for subsequent analyses, a range of slices of interest has to be selected, including the slice of maximal sternal depression, on which measurements for PE indices calculation are usually performed in clinic. This step has been implemented through a Graphical User Interface for selecting range of slices, slice for PE indexes computation, as well as patient’s gender. This is realized through `visualize_select` function
In order to improve low contrast inherent to CMR images, firstly we perform a contrast adjustment by remapping the values of the input intensity to fill the entire intensity range. Then, we focus exclusively on chest district by excluding arms placed at the borders of images, due to the small dimension of chest in pediatric patients. This is obtained by defining a proper mask, based on subject’s thorax morphology. Please refer to `border_control` and `mask_border` modules.

## Depression quantification:
This module has the goal to quantify the depression, based on a volumetric study. Indeed, rather than evaluating the depression on a single slice, as traditional radiological indices commonly adopted in clinical practice do, we propose to analyze multiple slices in order to measure the depression volume. The idea is to identify the two maximum and the minimum points of the outer chest contour for each slice considered (`outer_contour` function) and thus define an elliptic curve between the two maximum points in order to correct the depression and simulate the normal chest, in absence of PE malformation (`depression_eval` function). The difference between the chest image before and after image correction gives the amount of the depression.
In `main` function the new volumetric index, named Depression Factor is computed as follows: Depression factor=  (depression volume)/(correct chest volume)  * 100


## Inner chest contour segmentation:
This module aims at detecting the inner contour of the chest, fundamental for PE index calculation.
Firstly, the algorithm isolates the inner chest portion by exploiting histogram partitioning and lung segmentation (`hist_threshold` and `lung_segmentation`) as well as similarity between the inner and outer wall contour (`innercontour_seg` and `contour_interpolation`). Then, it excludes the vertebral body by thresholding method (`innermask_seg`). A user intervention is required here for selecting the starting slice for correction (`innermask_select`). Outcome of this step are provided by `inner_analysis` function, which gives binary mask of inner chest portion and lung segmentation after correction. 

## Thoracic indexes computation:
This module aims at computing PE indices used by physicians to classify the severity of patients’ malformation. As mentioned above, among multiple thoracic markers, we focused on the severity (Haller index and Correction index) and deformity (Asymmetry index and Flatness index) ones. The algorithm only works on the first slice of images processed in the previous module. Indeed, it corresponds to the slice selected by the user or to the first following one where inner chest contour can be detected (`contcorr_interpolation`). 
Once inner distances and thoracic indices are computed (`inner_index`), the framework saves their results along with the new pathological marker (depression factor) obtained in Depression quantification module in an Excel file, located in the same folder as patient’s images. Each quantified distance in following computations has been multiplied by ‘pixel spacing’ attribute in order to have measures in mm.

## Contributors:
Simona Martini, Rosella Trò 

