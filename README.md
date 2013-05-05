Remote Events for Corona SDK

by Remarkable Games
============
"Remote Events" is a small package we developed for debugging accelerometer events.
It includes two main modules:
1. Client app you can compile for iOS or Android and run from your device
2. Server module which you "require" in your project main lua which is ran on the Corona Simulator.

You will need to add the file "remoteEvents.lua" to your project root path.
Once you add the module to your project add the following line in "main.lua":
require( "remoteEvents" )

This will initialize a tcp listener on the simulator end. You will notice a small console window on the upper right corner of the screen.
This console will contain the module output (errors, events, etc), but the first thing you'll see in it is the IP your app is listening on.

Once you install the client app (build the main.lua provided in this package into a .app or .apk) on your device you should connect to the IP the server is listening on.
Edit the IP in the text field and press connect. If everything worked you should see an output on the simulator console.

Please feel free to contact us at remarkable.apps@gmail.com for more details.

This software is free to use as long as you don't sell it yourself :)
