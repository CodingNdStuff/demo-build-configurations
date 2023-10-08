# demo_build_configurations-flutter

A new Flutter project to develop build configuration scripts.

## Current capabilities
The scrips for now can:
- Parse a config.yaml file to get the flavors.
- Create launch.json + tasks.json in the .vscode folder to make build variants easy to access.
- Swap single .dart files based on the configuration, taking advantage of parallel lib folder copies.

## TODO
The scripts desired functionalities:
- Swapping whole directories.
- Including/excluding assets files. (work in progress, very buggy)
- Including/excluding assets directories.

## Setup & Usage
To test this in a new project:
- Create a new Flutter project using ```flutter create project-name```
- Drop the folder ```build_scripts``` in the top level of the newly created folder.
- Inside the folder you just copied, there should be a ```config.yaml``` file, otherwise create it following the example below.
- Run from terminal ```dart .\build_scripts\init.dart```. Based on your ```config.yaml``` file, this will create a ```.vscode``` folder containing two files:
    - ```launch.json``` : this one defines the varians that you can then select from the drop down menu in the ```Run and Debug``` section of VSCode.
    - ```tasks.json``` : this makes sure to run the scripts behind the scenes before building your app, swapping files and stuff.
- Select the flavor from the drop down menu and start debugging.

Note: ```dart .\build_scripts\init.dart``` should be run every time you update the ```config.yaml``` file.

## config.yaml example
Here's an example of ```config.yaml``` file:
```
flavors:
    multi:
    web: 
      - assets/Camille.png
      - lib/widgets/my_widget.dart
```

We can see that there are two flavors named ```multi``` and ```web```. This will generate 4 build variants for vscode : 
- MULTI-DEBUG
- MULTI-RELEASE
- WEB-DEBUG
- WEB-RELEASE

When multi is selected, nothing happens.
When web is selected, ```my_widget.dart``` in the lib folder will be replaced with the one in the parallel folder lib_web. If that folder does not exists, it will be generated the first time. It is up to the developer to then implement the content of the file.
