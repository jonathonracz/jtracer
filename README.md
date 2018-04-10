# jtracer

**jtracer** is a C++ raytracer capable of running either on the CPU (multithreaded or non-multithreaded) or as an Apple Metal compute kernel.

The raytracer was originally based on the implementation guide given by Peter Shirley's excellent ebook [Ray Tracing In One Weekend](https://www.amazon.com/Ray-Tracing-Weekend-Minibooks-Book-ebook/). The algorithms were modified to make the raytracer non-allocating (i.e. non stack based) by using color/light accumulators with a single ray object to trace through the scene.

The implementation found in [`jtracer/Trace`](jtracer/Trace) is designed to be extremely portable. It is a header-only implementation of a general GPU-compute compatible raytracer from a per-pixel standpoint given a set of scene parameters (in this case, a bunch of spheres). In theory, it should work in an OpenCL C++ or CUDA environment with little modification - likely just some system-specific definitions in [`JTTypes.h`](jtracer/Trace/JTTypes.h).

The frontend is written in Objective-C++. It is tested with Xcode 9.3 under macOS 10.13.4. The UI is extremely simple - all options are hardcoded within the app. On startup the main window will display two views: the top is a GPU-compute render via Metal, and the bottom is a multicore CPU render scheduled by `libdispatch` (Grand Central Dispatch). Below is a screenshot:

<img src="https://github.com/jonathonracz/jtracer/blob/master/screenshot.png?raw=true" alt="Screenshot, as described above.">
