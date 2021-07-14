# PE_pipeline
Matlab-based image processing pipeline in support of diagnosis of Pectus Excavatum patients.

Current framework is organized in four interconnected modules summarized below: Pre-processing, Depression quantification, Inner chest contour segmentation and Thoracic indexes computation. The software code has been developed in MATLAB® 2020a, running in Windows 10. 

![image](https://user-images.githubusercontent.com/58302565/125595264-331b32ee-87ce-4d07-9d46-761cdf072b14.png)

**Pre-processing:**
As a preliminary step for subsequent analyses, a range of slices of interest has to be selected, including the slice of maximal sternal depression, on which measurements for PE indices calculation are usually performed in clinic. This step has been implemented through a Graphical User Interface for selecting range of slices, slice for PE indexes computation, as well as patient’s gender. This is realized through `visualize_select` function
In order to improve low contrast inherent to CMR images, firstly we perform a contrast adjustment by remapping the values of the input intensity to fill the entire intensity range. Then, we focus exclusively on chest district by excluding arms placed at the borders of images, due to the small dimension of chest in pediatric patients. This is obtained by defining a proper mask, based on subject’s thorax morphology. Please refer to `border_control` and `mask_border` modules.

**Depression quantification:**




