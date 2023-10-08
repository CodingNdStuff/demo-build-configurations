// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';
import 'src/flavor.dart';
import 'src/flavors.dart';
import 'src/utils.dart';
import 'yaml-master/lib/yaml.dart';

void main() {
  File configFile = File('${Utils.path}/config.yaml');
  if (!configFile.existsSync()) {
    throw const FileSystemException(
        "Expected path: build_scripts/config.yaml. Make sure your directory tree mathes this path");
  }
  final yamlContent = configFile.readAsStringSync();
  final yamlMap = loadYaml(yamlContent) as Map<dynamic, dynamic>;

  final flavorConfig = Flavors.fromYamlMap(yamlMap);
  generateVscodeFolder(flavorConfig);

  print("DONE");
}

void generateVscodeFolder(Flavors flavorConfig) {
  Directory vscodeDir = Directory("${Utils.parentPath}/.vscode");
  if (!vscodeDir.existsSync()) vscodeDir.createSync();

  if (flavorConfig.flavors.isEmpty) {
    throw const FormatException(
        "There should be at least one flavor in config.yaml");
  }
  generateLaunchJson(flavorConfig, vscodeDir.path);
  generateTasksJson(flavorConfig, vscodeDir.path);
}

void generateTasksJson(Flavors flavorConfig, String path) {
  File outputFile = File("$path/tasks.json");
  String outputString = tasksJsonTemplate;
  for (Flavor flavor in flavorConfig.flavors) {
    String configString =
        tasksTemplate.replaceAll(flavorNamePlaceholder, flavor.name);
    configString += ",\n$tasksPlaceholder";
    outputString = outputString.replaceFirst(tasksPlaceholder, configString);
  }
  outputString = outputString.replaceFirst(",\n$tasksPlaceholder", "");
  outputFile.writeAsStringSync(outputString);
}

void generateLaunchJson(Flavors flavorConfig, String path) {
  File outputFile = File("$path/launch.json");
  String outputString = launchJsonTemplate;

  for (Flavor flavor in flavorConfig.flavors) {
    //debug
    String configString = configurationTemplate
        .replaceFirst(configurationNamePlaceholder,
            ("${flavor.name}-$debugString").toUpperCase())
        .replaceAll(flavorNamePlaceholder, flavor.name)
        .replaceFirst(flutterModePlaceholder, debugString);
    configString += ",\n$configurationsPlaceholder";
    outputString =
        outputString.replaceFirst(configurationsPlaceholder, configString);
    //release
    configString = configurationTemplate
        .replaceFirst(configurationNamePlaceholder,
            ("${flavor.name}-$releaseString").toUpperCase())
        .replaceAll(flavorNamePlaceholder, flavor.name)
        .replaceFirst(flutterModePlaceholder, releaseString);
    configString += ",\n$configurationsPlaceholder";
    outputString =
        outputString.replaceFirst(configurationsPlaceholder, configString);
  }
  outputString = outputString.replaceFirst(",\n$configurationsPlaceholder", "");
  outputFile.writeAsStringSync(outputString);
}

const String configurationsPlaceholder = "#config-list";
const String tasksPlaceholder = "#tasks-list";
const String configurationNamePlaceholder = "#config-name";
const String flavorNamePlaceholder = "#flavor-name";
const String flutterModePlaceholder = "#flutter-mode";
const String debugString = "debug";
const String releaseString = "release";
const String launchJsonTemplate = """{
  "version": "0.2.0",
  "configurations": [
#config-list
  ]
}""";

const String configurationTemplate = """    {
      "name": "#config-name",
      "request": "launch",
      "program": "lib/main.dart",
      "type": "dart",
      "flutterMode": "#flutter-mode",
      "preLaunchTask": "configureBuildPre-#flavor-name",
      "postDebugTask": "configureBuildPost-#flavor-name",
      "toolArgs": ["--dart-define", "FLAVOR=#flavor-name"]
    }""";

const String tasksJsonTemplate = """{
    "version": "2.0.0",
    "tasks": [
#tasks-list
    ]
}""";

const String tasksTemplate = """{
            "label": "configureBuildPre-#flavor-name",
            "type": "shell",
            "command": "dart",
            "args": [".\\\\build_scripts\\\\configure_build.dart", "'pre' '#flavor-name'"],
            "presentation": {
                "reveal": "always"
            }
        },
        {
            "label": "configureBuildPost-#flavor-name",
            "type": "shell",
            "command": "dart",
            "args": [".\\\\build_scripts\\\\configure_build.dart", "'post' '#flavor-name'"],
            "presentation": {
                "reveal": "always"
            }
        }""";
