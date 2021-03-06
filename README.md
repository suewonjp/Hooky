### DESCRIPTION
![](github/hooky-2016-03-28.png "Hooky")

Most of OS X users may use ⌘V (paste from the clipboard) everyday. _Hooky_ can assign another event such as _Mouse Middle Button Click_ to ⌘V so that you can paste data using Mouse Middle Click as well as ⌘V.

⌘V is one of easy keystrokes, so there may be little benefit to assign another event to it. But some shortcuts such as ⌥⌘8 (zoom in/out) might not be so easy to press. 

Hooky can be used to assign more easier and simpler events to existing shortcuts/hotkeys you use frequently.

Events being assigned such as _Mouse Middle Button Click_ are referred to as _Proxy Events_ in Hooky. Also the shortcuts to invoke such as ⌘V are referred to as _Target Shortcuts_.

Currently, Hooky offers two types of _Proxy Events_:
- **Mouse Click Events**
  - Long press, Single/Double/Triple click for any of left, right, middle buttons
  - One or more of Modifier Keys (⌘⌥⇧⌃) may be involved.
  - Note that long press needs you to release the mouse button to finally invoke the target shortcuts. (In other words, just holding down the button won't signal anything.)
- **Multiple Keystrokes on Modifier Keys** (MKM events)
  - Only works for **SINGLE** Modifier Key (⌘ or ⌥ or ⇧ or ⌃)
  - Long press on the modifier keys won't count. You should **TAP** on them!
  - No other regular keys or mouse buttons are involved.
  - Double/Triple/Quadruple tappings are supported 
      - Note that single tap is not supported because it will cause lots of conflicts.
  - e.g., You may _double tap on ⌥_ to switch applications instead of pressing ⌘-Tap.

And Hooky won't (more precisely, can't) modify any of target shortcuts. So users always have options of invoking the designated event by either of Hooky's proxy event or the original shortcut.

_**PLEASE, REFER TO THIS [BLOG](http://suewonjp.github.io/civilizer/blog/2016/03/30/Hooky/) FOR MORE DETAILS.**_

### BENEFITS
- Can assign complicated (so hard to press and hard to remember) shortcut keys to a simpler and easier type of events.
- Each or all of proxy events easily can be turned off and revived later.
- No elevated privilege (e.g., root) required
- No [Accessibility API](https://developer.apple.com/accessibility/osx/ "") being used 
  - So users **DON'T** have to deal with the hassle of Opening _System Preferences > Security & Privacy > Accessibility_ and registering Hooky as a legitimate app.
- Hooky is tiny. its resource footprint is small.

### LIMITATIONS
- Hooky might not detect any of events being used by higher privileged applications (including apps permitted to use Accessibility API)
- Hooky can't change the system or other application's behaviors associated with its proxy events. 
- Hooky can't detect non-modifier key strokes.

> Refer to this [blog](http://suewonjp.github.io/civilizer/blog/2016/03/30/Hooky/) for more details.

### SYSTEM REQUIREMENTS
OS X 10.9+

It has not been tested on 10.9 and 10.10.

Currently, it is being developed and tested on OS X 10.11+ with Xcode 7.3+.

### HOW TO INSTALL AND RUN
1. Download the latest .dmg file from [here](https://github.com/suewonjp/Hooky/releases/latest).
1. Double click the .dmg file and drag the .app file inside it into your _/Applications_ directory.
1. Open _Spotlight_ and type _Hooky_.
1. An icon that looks like a _hook_ will appear on the menu bar.
1. Clicking on that icon will bring up the window where you can register your _"proxy event/target shortcut"_ pairs.

### DEVELOPMENT REQUIREMENTS
- Xcode 7.2+

### COPYRIGHT/LICENSE/DISCLAIMER

    Copyright (c) 2016 Suewon Bahng, suewonjp@gmail.com
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

* * *
Written by Suewon Bahng   ( Last Updated 26 March, 2016 )

### CONTRIBUTORS
Suewon Bahng  

Other contributors are welcome!
