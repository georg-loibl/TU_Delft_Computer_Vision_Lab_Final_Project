# TU Delft Computer Vision Lab Final Project

This project was the final project of the Computer Vision course at the Delft University of Technology in 2019. My assigned project partner was [@martijnvwezel](https://github.com/martijnvwezel?tab=repositories).

The goal of the project was the 3D reconstruction of a model castle as well as a teddy bear by using a sequence of images made from different perspectives around the object.
The total project work is divided into five sections: Feature extraction and matching, RANSAC, Chaining, Stitching and the 3D visualization (for details, please have a look to our final report [here](/CV_Final_project_3D_reconstruction_Report.pdf)):

1. Feature extraction and matching using the Harris corner detector and SIFT:

<img src="/Pictures/02_Harris_Detector_teddy_bear_cut.png" width="30%" height="30%"/> <img src="/Pictures/02_Harris_Detector_castle_cut.png" width="33.8%" height="33.8%"/>

<img src="/Pictures/02_Teddy_first_150_matches_cut.png" width="50%" height="50%"/>

2. Filtering outliers by using the 8-point RANSAC algorithm

<img src="/Pictures/03_RANSAC_teddy_bear_120points_cut.png" width="50%" height="50%"/>
<img src="/Pictures/03_RANSAC_Model_castle_120points_cut.png" width="50%" height="50%"/>

3. Chaining - Tracking features that are visible from one to another frame

4. Creation and Stitching of point clouds

<img src="/Pictures/05_Teddy_SfM_OWN_features_front_cut.png" width="20%" height="20%"/> <img src="/Pictures/05_Castle_SfM_OWN_features_front_cut.png" width="20%" height="20%"/>

5. 3D visualization by assigning corresponding RGB values

<img src="/Pictures/06_Teddy_Visualization_3Dpoints_OWN_features_front_cut.png" width="25%" height="25%"/> <img src="/Pictures/06_Castle_Visualization_3Dpoints_OWN_features_front_cut.png" width="35%" height="35%"/>
# How to run the code

- Clone the repository.
- Download and install the latest version of VLFeat for Matlab [here](https://www.vlfeat.org/download.html) (neccessary for SIFT)
- Add the *Final_Project_CV* folder (and subfolders) as well as the downloaded VLFeat folder (and subfolders) to your path in Matlab.
- Edit the path of the folder in which you store your pictures in *FINAL_Project_CV.m*.
- Run the script *FINAL_Project_CV.m*.
- Adjust parameters to optimize results
