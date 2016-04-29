## Introduction

The [CM Storm Devastator Keyboard](http://www.amazon.com/CM-Storm-Devastator-Gaming-Keyboard/dp/B00DKXXAAQ/) is a great keyboard save for one shortcomming.... The backlight does NOT work on OSX. The keyboard backlight is mapped to the Scroll Lock Key, and unfortunately this key is not really used or mapped in OSX. 

Many people have tried to piece together a working solution, but most are far too technical for average users. Because of this, I have decided to make a simple OSX app that will allow a user to toggle the backlight of the CM Storm keyboard.

## How It Works
Follow the instructions bellow to the install the application. Once installed you need to grant the application access to control your computer. 

![alt text](https://github.com/Commander147/CMStorm/blob/master/screenshots/Screen%20Shot%202016-04-24%20at%2010.39.57%20PM.png?raw=true)

This may sound scary, but this permission is required so you can press **Shift + Scroll Lock to toggle the backlight now**. This project is open source, so feel free to compile it yourself instead.

In the top right corrner of yoru system tray, you will see "CM: On/Off" to represent the keyboard backlight status. 
![alt text](https://raw.githubusercontent.com/Commander147/CMStorm/master/screenshots/Screen%20Shot%202016-04-24%20at%2010.41.03%20PM.png)


## Installation

1. [Download this zip](https://github.com/Commander147/CMStorm/blob/master/Release/CMStorm_v1.0.zip)
2. Extract the CMStorm.app and copy it to ~/Applications/ directory
3. Run the CMStorm.app binary
4. You will be prompted to enable accesibility, press Open System Preferences, and press the checkmark next to CMStorm to enable access.
![alt text](https://raw.githubusercontent.com/Commander147/CMStorm/master/screenshots/Screen%20Shot%202016-04-24%20at%2010.40.12%20PM.png)
5. Relaunch the CMStorm.app binary, and you should be good to go!

## Usage

**Press Shift + Scroll Lock to toggle the backlight**

## Special Thanks

[Apple StackExchange](http://apple.stackexchange.com/questions/156273/os-x-cm-storm-devastator-keyboard-doesnt-light-up)

[Apple HID Demo Project](https://developer.apple.com/library/mac/samplecode/HID_LED_test_tool/Introduction/Intro.html)

[Apple Support Forum](https://discussions.apple.com/message/24471250#24471250)
