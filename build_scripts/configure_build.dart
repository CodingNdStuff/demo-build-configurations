// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';
import 'src/flavor.dart';
import 'src/flavors.dart';
import 'yaml-master/lib/yaml.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    throw FormatException(
        "Expected 2 argument, but found ${arguments.length}.");
  }

  FlowType flowType = FlowType.stringToEnum(arguments[0]);
  String flavorName = arguments[1];

  File configFile = File('build_scripts/config.yaml');
  if (!configFile.existsSync()) {
    configFile = File('config.yaml');
    if (!configFile.existsSync()) {
      throw const FileSystemException(
          "Expected path: build_scripts/config.yaml. Make sure your directory tree mathes this path");
    }
  }

  final yamlContent = configFile.readAsStringSync();

  final yamlMap = loadYaml(yamlContent) as Map<dynamic, dynamic>;

  final flavorConfig = Flavors.fromYamlMap(yamlMap);
  Flavor flavor = flavorConfig.getFlavor(flavorName);

  //processAssets(flavor.assetsToInclude, flowType);
  processClasses(flavor.name, flavor.classesToInclude, flowType);

  print("DONE");
}

void processAssets(List<String> assetsToInclude, FlowType flowType) {}

void processClasses(
    String flavorName, List<String> classesToInclude, FlowType flowType) {
  for (String classFile in classesToInclude) {
    File startFile =
        File("$cwd/${classFile.replaceFirst("lib", "lib_$flavorName")}");
    File destFile = File("$cwd/$classFile");

    if (!startFile.existsSync()) startFile.createSync(recursive: true);
    if (!destFile.existsSync()) destFile.createSync(recursive: true);

    String startFileContent = startFile.readAsStringSync();
    String destFileContent = destFile.readAsStringSync();

    if (flowType == FlowType.pre && !startFileContent.contains(annotation)) {
      startFileContent =
          "  ${annotationTemplate.replaceFirst("@", flavorName)}\n$startFileContent";
    }

    if (flowType == FlowType.pre && !destFileContent.contains(annotation)) {
      destFileContent =
          "  ${annotationTemplate.replaceFirst("@", "DEFAULT")}\n//  YOU CAN LEAVE THIS ONE EMPTY.\n$destFileContent";
    }

    startFile.writeAsStringSync(destFileContent);
    destFile.writeAsStringSync(startFileContent);

    print("Moving ${startFile.path} into ${destFile.path}");
    print("Moving ${destFile.path} into ${startFile.path}");
  }
}

const cwd = ".";
const annotation = """//###FLAVOR:""";
const annotationTemplate = """//###FLAVOR: @###""";

enum FlowType {
  pre,
  post;

  static FlowType stringToEnum(String value) {
    for (FlowType flowType in FlowType.values) {
      if (flowType.name == value) {
        return flowType;
      }
    }
    throw ArgumentError(
        'Invalid argument value: $value. Accepted values are ${FlowType.values.map((e) => e.name)}');
  }
}
