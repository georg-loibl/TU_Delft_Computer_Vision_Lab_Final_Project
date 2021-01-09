# TU Delft Computer Vision Lab Final Project 2019

This project was the final project of the Computer Vision course at the Delft University of Technology in 2019.
The goal of the project was the 3D reconstruction of a model castle as well as a teddy bear by using multiple images from different perspectives around the object.
The necessary steps to achieve this goal are the following (for details, please have a look to our final report LINK):

1. Feature extraction and matching using the Harris corner detector and SIFT:

PICTURE

2. Filtering outliers by using the 8-point RANSAC algorithm

PICTURE

3. Chaining - Tracking features that are visible from one to another frame

4. Creation and Stitching of point clouds

PICTURE

5. 3D visualization by assigning corresponding RGB values

PICTURE

# How to run the code

- Clone the repository.
- Download and install the latest version of VLFeat for Matlab [here](https://www.vlfeat.org/download.html) (neccessary for SIFT)
- Add the *Final_Project_CV* folder (and subfolders) as well as the downloaded VLFeat folder (and subfolders) to your path in Matlab.
- Run the script *FINAL_Project_CV.m*.
