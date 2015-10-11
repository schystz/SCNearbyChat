# SCNearbyChat
An iOS application which lets you discover and chat nearby users without using internet connection. This is made possible by Apple's MultipeerConnectivity framework.

# Instructions
- Clone the project to your local machine
  - `git clone https://github.com/schystz/SCNearbyChat.git`
- Run `pod install` at the root directory to install dependencies
- Open SCNearbyChat.xcworkspace and run the app
- You may test the app on the Simulator and an actual iPhone or iPad

# Issues
There seems to be somes issues on MultipeerConnectivity framework.
- You may find some duplicate peers appearing on the list.
- Sometimes it is also hard to connect with a discovered peer. `session:peer:didChangeState:` always returns a `NotConnected` state even though other peer has accepted the invitation.
