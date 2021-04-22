# Flash-Reflection-Image-Treatment
In this small code, I erase the reflection caused by the flash of my smartphone by grouping 4 images of the same object taken at different angles. I accomplish this by correlating all the images, making a DLT (Direct Linear Transformation) and calculating the median of this different image.
You can see that the MatLab code is divided in 2 sections, the upper one is the manual selection of the points, and the bottom one is the automatic selection of the points.

Input:

<a href="https://gyazo.com/57bb44e7c07f9b04b0e37df74eb517b7"><img src="https://i.gyazo.com/57bb44e7c07f9b04b0e37df74eb517b7.png" alt="Image from Gyazo" width="300"/></a>

Output (using manual point selection):

<a href="https://gyazo.com/9b830d9a683fbb1111c0082a2511ff31"><img src="https://i.gyazo.com/9b830d9a683fbb1111c0082a2511ff31.png" alt="Image from Gyazo" width="200"/></a>

Output (using detectSURFFeatures, automatic point selection):

<a href="https://gyazo.com/e3ab7759b90ac9f41a70a4b3d733eaa4"><img src="https://i.gyazo.com/e3ab7759b90ac9f41a70a4b3d733eaa4.png" alt="Image from Gyazo" width="200"/></a>
