# Ena wasawasa levu. Auf dem weiten Meer
(en: Ena wasawasa levu. On the Open Sea) 

A VR project of the Staatliche Museen zu Berlin - Preußischer Kulturbesitz in the context of museum4punkt0 for the Ethnological Museum of Berlin in the Humboldt Forum.

In the VR experience, the player learns about the different ways people in the Pacific navigate the sea using the signs of nature. The game is structured in four levels, which need to be solved to win the game: Players have to navigate with the help of the sun, the stars, clouds and the birds.  
The players start on a traditional canoe near an island in the Pacific. They meet a navigator that explains the task they are up to: reach the next island by using the natural signs around them. To select objects in the game the players have to look at it and place the cursor on it. The movement of the boat is controlled by the controller the players have in their hand and using the rudder on the boat.  

This VR exhibit is part of the project museum4punkt0 - Digital Strategies for the Museum of the Future. Further information: [www.museum4punkt0.de/en/](https://www.museum4punkt0.de/en/).  
The project museum4punkt0 is funded by the Federal Government Commissioner for Culture and the Media in accordance with a resolution issued by the German Bundestag (Parliament of the Federal Republic of Germany).

The project produces a Windows application contained in an installer
that enables setting up the application for auto-start after booting the PC.  

**This file documents the *Ena wasawasa levu. On the Open Sea* project for developers and system administrators. It is not a manual for end users or museum hosts.**

For end users or museum hosts, see the manual.

<h2>Contents</h2>

- [Technical requirements for running the application](#technical-requirements-for-running-the-application)
  - [Hardware](#hardware)
  - [Software](#software)
- [Running the application](#running-the-application)
  - [Application Settings](#application-settings)
  - [Keyboard shortcuts](#keyboard-shortcuts)
- [Source](#source)
  - [Overview of components: Scenes](#overview-of-components-scenes)
  - [Overview of components: Code](#overview-of-components-code)
  - [Main Game: Assignments](#main-game-assignments)
  - [Compiling the application and the installer](#compiling-the-application-and-the-installer)
  - [Third-party package requirements](#third-party-package-requirements)
  - [Third party applications needed to build the project](#third-party-applications-needed-to-build-the-project)
- [Credits](#credits)
- [License](#license)

## Technical requirements for running the application
### Hardware
* A Windows 10 PC with a powerful, VR-capable graphics card.
* HTC Vive Pro with base stations, and one controller.

In the installation at the museum, two dedicated PCs will be used:
**Dell Precision 5820 Tower XCTO Base**
  * Intel Core i7-7800X 3,5GHz, 4GHz Turbo, 6C 8,25MB Cache, HT, (140W) DDR4-2400
  * 32GB (4x8GB) 2666MHz DDR4 UDIMM
  * NVIDIA GeForce GTX 1080

Two Vive Pro headsets will use the same two base stations.
Additionally in the museum, each PC will have a small screen built into the set,
and an [Elgato Stream Deck Mini](https://www.elgato.com/de/gaming/stream-deck-mini) that will serve as a keyboard replacement for some shortcuts.

### Software
* [Steam](https://store.steampowered.com/about/) and SteamVR need to be installed on the PC (minimum version 1.7.15)
* When using the Stream Deck Mini, install the [Stream Deck application](https://www.elgato.com/de/gaming/downloads).

#### SteamVR Settings
Check that the version of the SteamVR application is 1.7.15 or higher.

![SteamVR-version](Documentation/images/SteamVR-version.png)

Click the menu button (the hamburger icon in the top left of the window) to open the _Settings_ window of the SteamVR application, and select the _Developer_ section.

![SteamVR-version](Documentation/images/SteamVR-settings.png)

* Uncheck the setting called **Enable VR Dashboard**.
  This will prevent the user quitting the VR experience by pressing the system button on the Vive controller.
  
  Note that in version 1.9 of SteamVR this setting is moved to the _General_ section, renamed to **VR Dashboard on System Button**, and is only visible when the _Advanced Settings_ are set to **Show**:
  ![SteamVR-version](Documentation/images/SteamVR-settings-1.9-2.png)
* Check the setting called **Do not fade to grid when app hangs**.
  This will prevent SteamVR from displaying an abstract world when the VR application is loading a new scene.  
  
  Note that in version 1.9 of SteamVR this setting is moved to the _Video_ section, and is now called **Fade to Grid on app hang**:
  ![SteamVR-version](Documentation/images/SteamVR-settings-1.9.png)

#### Stream Deck profile (optional)
The installer puts a Stream Deck Profile file on the desktop, for importing into the Stream Deck software.
The profile is set to be the default profile. This means it is always active.
You may want to change it to only be active when the application is running.  
More information on configuring the Stream Deck is available in the [Stream Deck Quick Start Guide](https://help.elgato.com/hc/en-us/articles/360028241291-Elgato-Stream-Deck-Quick-Start-Guide).

The profile contains keyboard shortcuts for changing languages, restarting the game and skipping to the end sequence.
These work exactly the same as the normal keyboard shortcuts mentioned below, but will only work if the application is also playing.  
There's also two buttons to restart the computer, or shut it down.
These always work, whether the application is playing or not.

![StreamDeck-profile](Documentation/images/StreamDeck-profile.png)

**Note that the batch files that are called by the restart and shutdown buttons were provided by the client. IJsfontein has implemented these into the configuration, but cannot offer support, if they don't work as expected.**

## Running the application

### Application Settings
Settings are stored in a JSON file called `settings.json` in the user's Documents folder, in a folder with the name of the application. For the release version of the application, that is `C:\Users\<Username>\Documents\VR-Wasawasa-release`.

Settings are read once, right after launching the application.
When the settings file does not exist, it is created with default values.
Change settings by quitting the application, locating the settings file, editing and saving it.
If the file has become unparseable after editing, a new one with default values will be created and used at the next application launch.
Deleting the settings file will make the application revert to defaults at the next launch.

Settings that can be changed are:
* **Game Duration** (in minutes)
  Defines play time before end sequence is triggered, not counting the time spent choosing language.
  Default value: 15.0
* **End Screen Duration** (in minutes)
  Defines how long the end screen stays after the player reached the end island.
  Default value: 1.0

Both values are floating point variables, but integer values will work too.

#### Default settings
```
{
    "gameDurationMinutes": 15.0,
    "endScreenDurationMinutes": 1.0
}
```

### Keyboard shortcuts 

These keyboard shortcuts are only useful for system administrators or maintenance.  
For normal use, the Stream Deck provides some of the shortcuts listed here, marked with a *.

#### General
  * <kbd>alt</kbd>+<kbd>F4</kbd> quit
  * <kbd>F2</kbd> open settings file
#### Language selection screen
  * <kbd>1</kbd> (on the alphanumeric keyboard) choose German and start the game *
  * <kbd>2</kbd> choose English and start the game *
  * <kbd>F5</kbd> check for update availability of the game (internet connection required)  
    Note that this doesn't check for possible updates in other required software like Steam and Steam VR
  * <kbd>shift</kbd>+<kbd>F5</kbd> download and install update (when available)
#### Main game
  * <kbd>esc</kbd> go back to the language selection screen *
  * <kbd>=</kbd> trigger timeout (skip to end scene with "too late" ending) *
  * <kbd>1</kbd> (on the alphanumeric keyboard) switch to German *
  * <kbd>2</kbd> switch to English *

## Source

The project can only be edited and built with Unity 2019.2.x (x: 15f1 or higher), because we use a version of the [Crest Ocean System](https://github.com/crest-ocean/crest) that was not compatible with Unity 2019.3 or higher at the time we imported it.  
Updating Crest to a newer version will undo some of the small adjustments we made, and other changes in the Crest package cause things to behave differently.  
For this reason, don't update the Crest source unless you are prepared to adjust or refactor the `Boat` and `Ocean` components.

### Overview of components: Scenes

The game is separated in two scenes: _Intro_ and _Main_. They are located in the project folder under `Assets/VR-Navigation/Scenes`.

#### Intro scene

This is the Language Selection scene. It is where new users start when they put on the headset. 

This scene contains 
* the **Language Selection** menu, 
* the **Player** prefab that contains the VR camera controlled by the player through the Steam VR system, and a **Gaze Input** component that enables the player to look at **GazeButton**/**GazeTimer** objects and select them, 
* an **Ocean** component,
* a **Soundscape** background music object,
* an **Updater** component that checks for available updates,
* a **Dashboard Canvas** that displays version info and lists connected VR controllers,
* the **Main** component that handles loading of the _Main_ scene, fading sound and VR image in and out, upon selection of the user's preferred language.

#### Main scene

This is the main game. It starts with a tutorial phase in which the purpose of the game and the controls are explained.
After that, the player starts sailing to the first assignment.

This scene contains
* the **Main** component that handles state changes of the game, activates and deactivates the relevant GameObjects in the level, resets some shader values;
* the **LanguageSwitcher** that handles in-game language switching by handling the keyboard presses;
* the **ADS** GameObject that holds global settings for the _Advanced Dynamic Shaders_ materials and shaders used in the game;
* the **Transitions/DayToNight** GameObject that controls the transition of the day into night, by animating (using the _DayToNight_ Timeline asset) the position of the sun, the visibility of the clouds and stars and the wind particle system;
* the **FeedbackProgress** Gameobject that controls the feedback on the player's progress in the game: it animates (using the _Achievements_ Timeline asset) the visibility of stamps on the boat's sail, and particles when an assignment was completed;
* the **Sun** GameObject that contains the Directional Light that is the sun; it is rotated via the _DayToNight_ Timeline;
* the **Ocean** GameObject that represents the sea;
* the **Ocean Inputs** GameObject that defines the Ocean component's behaviour;
* the **Boat + Player** Gameobject that represents the player's sail boat, containing the rudder that steers the boat, and the same **Player** prefab as in the Intro scene;
  * The GameObject **Boat + Player/Paddle Origin/Dragger** is the object that is grabbed by the SteamVR Controller, and when moved controls the steering of the boat;
  * The boat also contains a number of GameObjects that hold the Turtle's help animation Timelines and the Timelines for the Navigator's poems. These are switched on and off depending on the state of the game;
  * The boat contains a number of AudioSources that play different sounds, such as when the boat collides with reefs, the sound of the sea and the sail;
* the **Level** Transform holds all relevant objects for the different assignments, as well as the _Start_ and _Finish_ island models;  
* the **Audio** Transform contains a number of audio sources that are triggered througout the game, for the sea and wind soundscapes, the sound when doing an assignment, and calls to action ("Now sail west!").

### Overview of components: Code
**Where necessary, comments on relevant functionalities and their interfaces to other program parts are in the relevant places in the code.**

All code specific to the game is located in the directory `Assets/VR-Navigation/Scripts`.

The main entry points of the _Intro_ and _Main_ scenes are the `Main` classes in `Scripts/Intro/Main.cs` and `Scripts/Main/Main.cs` respectively.

#### Main Game: Context and States
Game state is managed with the classes located in `Scripts/GameStates`.  
All Game States have a reference to the `GameContext` instance.  
The `GameContext` class has a reference to the `GameStateMachine` instance that is in the `Assets/IJsfontein/Runtime/GameStates` folder.  

The first Game State (`GameStateInit`) is created by the `Main` Script Component attached to the **Main** GameObject in the _Main_ scene.  

`GameStateInit` initializes the game and progresses to the next states listed here in order of appearance in the game: 
* `GameStateNavigatorIntro`
* `GameStateTurtleIntro`
* `GameStateSailToAssignment` (with `Main.LayerName.Start` parameter)
* `GameStateSunAssignment`
* `GameStateSailToAssignment` (with `Main.LayerName.SailWest` parameter)
* `GameStateStarsAssignment`
* `GameStateSailToAssignment` (with `Main.LayerName.SailSouth` parameter)
* `GameStateCloudsAssignment`
* `GameStateSailToAssignment` (with `Main.LayerName.SailToBirds` parameter)
* `GameStateBirdsAssignment`
* `GameStateSailToAssignment` (with `Main.LayerName.SailToIsland` parameter)
* `GameStateParty`

The last Game State (`GameStateParty`) loads the _Intro_ scene when it is done (either by time out or when the user takes off the headset).

#### Main Game: Layers
All Game States activate the neccessary GameObjects for their part of the game through the `ElementsLayerSwitcher` instance that is referenced via the `GameContext` class.   
The `ElementsLayerSwitcher` Script Component is attached to the **Main** GameObject in the _Main_ scene.  
This Component holds lists of GameObjects organised in the `Layers` array, where each `ElementsLayer` contains a list of GameObjects that will be switched on when the layer is activated.  
All GameObjects in other layers that are not also present in the layer that will be activated, will be switched off.  
All GameObjects that are in the scene but not in any ElementsLayer list, will not be switched on or off.

### Main Game: Assignments

The flow of the game, after the introduction, consists of sailing to an Assignment, and then playing the Assignment. 
When an Assignment is completed, this triggers the next sailing trip.  

Assignments typically consist of a Poem read by the Navigator's voice, accompanied by a Timeline animation. 
When the Poem's Timeline is finished, the assignment is activated. 

Completing an assignment is done by looking at one or more elements in the surroundings, through the `GazeInput` Component in the **Player** prefab that triggers `GazeTimer` GameObjects in the scene.   
The currently active `GameStateAssignment` instance listens for these Gaze Timer events. It handles feedback on the player's actions, by checking if the triggered `GazeTimer` component is a correct or incorrect one.

When all required Gaze Timer objects have been triggered, the Assignment State starts the feedback routine, after which the next phase of the game starts: 
The `GameContext` class handles the sequence of Assignments and each Assignment state, upon completion, triggers the `SetSailToAssignmentState` method of the Game Context with an incremented assignment index.

Sailing to an Assignment is completed when the **Boat+Player** GameObject collides with the active `NavLocationTrigger` Component in the scene. This is also true for the last sailing stretch to the final island.

### Compiling the application and the installer

The process of building both the application and the installer can be started in the Unity Editor by opening the project, choosing "Build Windows exe and Installer" from the **Tools > Humboldt-Forum** menu.

Alternatively, it can be started from the command line, as below:

    ${UNITY} -logFile build.log -projectPath "${PROJECT_PATH}" -quit -batchmode -executeMethod HumboldtForum.Build.Windows.BuildExeAndInstaller -build ${BUILD_NUMBER} -version ${APP_VERSION} -branch "${CHANNEL}" -setupName "VR-Wasawasa-setup-${CHANNEL}" -forgetProjectPath

Change the items between `${ }` for the values needed:
  * `UNITY` is the full path to the Unity Editor application
  * `PROJECT_PATH` is where the Unity project is located: the folder containing the _Assets_ directory; a full path or relative to your current directory
  * `BUILD_NUMBER` and `APP_VERSION` define the version and build numbers to be used
  * `CHANNEL` is typically used to separate alpha, beta and release versions. It controls which channel the updater in the application uses to check for updates.

Both options require Inno Setup 5.5.9 (see [below](#third-party-applications-needed-to-build-the-project)) to be installed in its default location: `C:\Program Files (x86)\Inno Setup 5\ISCC.exe`

Building the installer can only be done on a Windows computer.

### Third-party package requirements

#### Copyrighted but free (included in source distribution)
* [Crest Ocean System](https://github.com/crest-ocean/crest) (MIT License)  
  This is used for the ocean simulation, boats and waves.
* [SteamVR Unity plugin](https://github.com/ValveSoftware/steamvr_unity_plugin) ([BSD 3-Clause "New" or "Revised" License](https://github.com/ValveSoftware/steamvr_unity_plugin/blob/master/LICENSE))  
  Used for VR support
* [DOTween](http://dotween.demigiant.com/) (Free to distribute without modifications, see [License](http://dotween.demigiant.com/license.php))  
  Used for coded animations
* [Playable Shader Globals](https://github.com/slipster216/PlayableShaderGlobals) (MIT License)  
  Used to animate certain shader values
* [Stylized Procedural Skybox](https://github.com/DMeville/AmplifyShaderCommunityExtras/tree/master/Assets/ASECommunityExtras/ShaderGraphs/StylizedProceduralSkybox) (Part of [Amplify Shader Editor Community Extras](https://github.com/DMeville/AmplifyShaderCommunityExtras), MIT License)  
  Used to make the sky look better

#### Not included in open source distribution
These packages are available in the Unity Asset Store, and are licensed under the standard [Unity Asset Store End User License Agreement](http://unity3d.com/company/legal/as_terms).  

* [Amplify Shader Editor](https://assetstore.unity.com/packages/tools/visual-scripting/amplify-shader-editor-68570)  
  Used to edit shaders, not needed for compiling the final product
* [Bird Flock Seagull](https://assetstore.unity.com/packages/3d/characters/animals/bird-flock-seagull-4538)  
  Provides the base behaviour for the birds in the game  
  > Once downloaded, install this package in the `Assets/Bird Flocks` placeholder directory
* [Boxophobic Advanced Dynamic Shaders](https://assetstore.unity.com/packages/vfx/shaders/advanced-dynamic-shaders-unified-wind-shaders-for-any-vegetation-115838)  
  Shader system for the sail and flags
  > Once downloaded, install this package in the `Assets/BOXOPHOBIC` placeholder directory
* [Curvy Splines](https://assetstore.unity.com/packages/tools/level-design/curvy-splines-7038)  
  Provides the base for spline path animations
  > Once downloaded, install this package in the `Assets/Curvy Splines` placeholder directory

### Third party applications needed to build the project
* [Unity 2019.2.x](https://unity3d.com/get-unity/download/archive)
* [Inno Setup 5.5.9](http://files.jrsoftware.org/is/5/innosetup-5.5.9.exe) ([License](https://jrsoftware.org/files/is/license.txt))  
   Only necessary to make the installer

## Credits

Contracting entity: Staatliche Museen zu Berlin - Preußischer Kulturbesitz

Authorship: Staatliche Museen zu Berlin - Preußischer Kulturbesitz / Wegesrand Interactive GmbH 

Design and Programming: IJsfontein

## License

MIT License

Copyright © 2020, museum4punkt0 - Staatliche Museen zu Berlin / Wegesrand Interactive GmbH in co-operation with IJsfontein BV  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

