# Godot Accessibility Plugin

_Warning: Still in early development. Only use if you're willing and able to roll up your sleeves and help._

This plugin implements a screen reader for user interfaces created with the [Godot game engine](https://godotengine.org). The goal is to enable the creation of [audio games](https://en.wikipedia.org/wiki/Audio_game) with Godot, as well as to add accessibility functionality to user interfaces and to encourage the creation of accessible games.

## Why?

As a blind gamer and software developer, I've long had an interest in developing games. But while I can assemble and integrate bunches of individual libraries to achieve the functionality I need, game engines already ship battle-tested components for almost every feature I could possibly want. Accessibility is a glaring exception.

If so many developers are flocking to engines like Unity, it must be that they derive some advantage from the platform. But because the Unity development environment isn't accessible, I as a blind developer have no way of knowing whether that style of development would work for me. This addon is my way of exploring those possibilities.

Anecdotally, I've learned that building games with Godot is not only possible, but is becoming very fast as I refine my workflow. My process probably looks nothing like that of most other Godot users. I use the editor to set up scenes, edit properties, etc. Then I drop to a shell prompt, edit the _.tscn_ files by hand, then run the game from the shell. The editor is more of an exploratory interface for the work I mostly do by hand. But even though this approach is a bit more obtuse than just picking a scripting language, what I get from Godot is a set of components that can perform just about any game-related task I need. I also can export games to just about any platform--Windows, Linux, MacOS, Android, iOS, and UWP for the Xbox One.

## Installation

There is an [accessible starter project](https://gitlab.com/lightsoutgames/godot-accessible-starter) that does most of this for you, and sets up a basic project with an in-game screen reader and editor accessibility. But here are the steps from an empty Godot project:

1. Place this repository in a directory named _addons/godot-accessibility_ inside your project. This plugins files should be reachable at the Godot path _res://addons/godot-accessibility_.
2. Download the [latest release of the Godot TTS plugin](https://gitlab.com/lightsoutgames/godot-tts/-/jobs/artifacts/master/download?job=publish) and place its files in _addons/godot-tts_. When complete, you should have paths like _addons/godot-tts/TTS.gd_.
3. Enable the Godot Accessibility plugin from the editor UI. Or, if you have a _project.godot_ file, ensure that you have a section like:
```
[editor_plugins]

enabled=[ "godot-accessibility" ]
```
4. Optionally, configure the plugin by creating a file named _.godot-accessibility-editor-settings.ini_ in your project directory. This file is entirely optional, and defaults ar shown below:
```
[global]
editor_accessibility__enabled = true ; Set to false if you'd like this plugin's accessibility nodes but don't need editor speech, good for sighted collaborators.
[speech]
rate = 50 ; range is 0 to 100.
```
5. Launch your project by running `godot -e` in the top-level directory.

## What is provided?

### `ScreenReader` node

Add the `ScreenReader` node to any `SceneTree` to make any UI accessible. Many of the most common UI controls are supported.

`ScreenReader` also customizes keyboard handling to account for the fact that Godot's is lacking by default. It attempts to set an initial focus whenever a new scene is initialized.

### Editor accessibility

Since the Godot editor is itself a Godot UI, the plugin optionally injects a `ScreenReader` node into the editor. The interface isn't accessible enough to create games entirely from within the editor, but games can still be created by using Godot's editor to get an idea for how files should be structured, then editing them by hand in a more accessible IDE.

## Gotchas

Here are some issues that I know about now, along with recommended workarounds where possible:

### Shift-tab doesn't work in the latest Godot beta.

Stick with 3.1.2 for now. This is fixed, but not available in a beta build yet.

### Sometimes Tab and Shift-tab stop working.

If focus ever lands outside of a UI widget, Tab and Shift-tab will stop working because there is no focused control for which to find a new focus candidate. I have some defensive code in place to recover from this sometimes, but it still happens on occasion. Save often.

### File navigation is confusing.

Yeah it is, and I'm not immediately sure of a fix. This is where I need a sighted person to help me understand the layout of some of these dialogs, along with the behavior of the controls they contain. They're usable but confusing. Here is my workflow for opening a scene. Say I have _scenes/Player/Player.tscn_ in my project and want to open it:

1. Press Ctrl-o.
2. Tab until I hear "Path".
3. Tab once more. I'm now on an editable text field that speaks something like "res://scenes/Main".
4. Update this to be "res://scenes/Player" (I.e. the directory containing _Player.tscn_. Press _Enter_.
5. Tab until I hear "File". Tab once more and I'm on the filename.
6. Update this to read "Player.tscn" and press _Enter_.

The Player scene should now be loaded, and tabbing bunches of times should land you on the node tree. Speaking of:

### I'm going to break a finger tab/shift-tabbing everywhere.

I know. This interface was designed for mouse users. I can probably add a hotkey for jumping between major UI elements, but as a blind developer, I don't know the boundaries of these major UI areas. Help with this would be greatly appreciated.

One promising area of exploration is Godot 3.2's ability to disable editor features. Audio-only games might get away with disabling 3-D and other views, thus at least minimizing tab fatigue. But that feature crashed when I last attempted it (3.2 alphas) and I haven't tried again.

### Some controls don't work.

Working on it. Help welcome, since sometimes I can't figure out how a control is intended to work.
