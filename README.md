# SceneKit-Playground
A demo app utlizing SceneKit and other frameworks

## Overview

This is a demo project for learning how to integrate other frameworks with `SceneKit`

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/cameracontrol.gif?raw=true)

## Camera Controller 

One of the challenges of working with `SceneKit` is dealing with the camera, and how to interact with it.
For this I made a custom controller that uses the pan gesture in the `UIScrollView` to move around a `UILabel` as a controller. you free "rubber banding" from using the scroll view. 
You can change the values of the controller by swiping down on the top section. 

## Motion Controller

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/tiltcontrol.gif?raw=true)

Double tap the top View and it will enable controlling the camera by using the device's gyroscope.
I hadn't done anything with `CoreMotion` up until now.
Learning about the maths involved along with the physics was much needed. 

## Front Facing Video Texture 

If you flick the switch in the top left corner it will swap out the material of the box in the center with your reflection. it grabs the preview layer from the front facing camera and puts wraps it around the cube. 
