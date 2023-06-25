# 2D implementation of Boids using SpriteKit and Swift 5.

## Overview
Boids is an artificial life program, developed by Craig Reynolds in 1986, which simulates the flocking behaviour of birds. The name "boid" corresponds to a shortened version of "bird-oid object", which refers to a bird-like object.
As with most artificial life simulations, Boids is an example of emergent behavior; that is, the complexity of Boids arises from the interaction of individual agents (the boids, in this case) adhering to a set of simple rules.

## Rules:
> **1. Separation:** steer to avoid crowding local flockmates <br/><br/>
> **2. Alignment:** steer towards the average heading of local flockmates <br/><br/>
> **3. Cohesion:** steer to move towards the average position (center of mass) of local flockmates

Common thing that everyone does is checking only for neighbours in front view, but i wanted more FPS. Also, i've added reaction to touch, so boids move from touch position if near
## Preview:
Start of simulation

<img src="/Artwork/start.gif" width="660">

Touch reaction

<img src="/Artwork/touch.gif" width="660">
## Performance:
On IPad 6th generation it can simulate 4096 nodes in 30 fps. Im using Spatial Hashing algorithm as searching method with Time complexity _O(n\*m\*k)_, where n is number of nodes, m is number of grids to search through and k is number of nodes in one grid cell. Now current bottleneck is calculations and some system proccess(was not able to identify, because Instruments was not able to identify process time). <br/><br/>
When a lot of boids are in one location, it can have lag spikes, because larger boid density. In theory it can be fixed by limiting boid neighbourhood count, but it was not a big improvement, so i removed neighbourhood cap. <br/><br/>
Also, spritekit physics simulation was bottleneck at some point, so i removed physics entirely from project and now using SpriteKit only for SpriteNode class. As side effect, nodes now move only when update() occurs, that means lower fps-slower boids, but much better performance in general.

## Ways of improvment:
I've done everything that i wanted with this project, but noticed some things that can be improved\done differently. Here is the list of some of them:
> **1. Multithreading:** I tried using GCD, but in that scenarios performance was much worse than single threaded version. Maybe multithreading is not suitable for this type of project? Maybe i was doing something wrong? Maybe it needs usage of lower level or much more careful thread usage? Idk. <br/><br/>
> **2. NAND operations:** It can reduce performance cost of calculating stuff. A lot of simple data can be put in vectors and then calculated to give wanted result. <br/><br/>
> **3. METAL:** In theory using metal to create and draw objects can be better for performance than SpriteKit. <br/><br/>
> **4. Less CLEAN code:** Moving computation from different methods in Boid class to one for loop can be better performance vise, not much, but still. <br/><br/>
> **5. Using SKShapeNode:** Maybe using SKShapeNode can be better, but i forgot to try. <br/><br/>
> **6. Removing rotation:** If there is a lot of nodes, they can be represented as dots and also remove rotation as redundant. <br/><br/>
> **7. Replacing teleportation with additional rule:** Currently it checks if boid location is outside of border. If it is, then teleports to the other side. Maybe rule(christopherkriens's Boids have this rule), that makes them turn around, can be better. <br/><br/>
> **8. Adjusting values:** There is file called Preferences.swift that have every value that project utilize. Maybe, if adjust some values of distances, it can give better simulation or fps. <br/><br/>
> **9. Other search algorithms:** Currently spatial hash grid is the best for me. I tried QuadTree and it was worse. I could try KDTree, but i already have wanted level of performance. Also worth trying implementing multithread friendly method. <br/><br/>
> **10. Using timestamps:** Currently, boids move only in update() func, therefore the lower fps->slower boids. It also means that if a lot of boids are in one place, lag will be there longer, because this situation is calculated for more time. Adding timestamp consideration can make simulation smoother. SpriteKit have this built-in in physics simulation, but it also used more CPU, so i removed it.

## Source Versioning
Xcode 14.3.0

iOS SDK 16

Swift 5.8

## Credit:
**Pseudocode:** Conrad Parker (2007). [Boids Pseudocode](http://www.kfish.org/boids/pseudocode.html)

**Reference project in some points:** christopherkriens [Boids](https://github.com/christopherkriens/boids)
