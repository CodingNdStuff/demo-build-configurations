// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';
import 'src/flavor.dart';
import 'src/flavors.dart';
import 'src/utils.dart';
import 'yaml-master/lib/yaml.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    throw FormatException(
        "Expected 2 argument, but found ${arguments.length}.");
  }

  FlowType flowType = FlowType.stringToEnum(arguments[0]);
  String flavorName = arguments[1];

  File configFile = File('${Utils.path}/config.yaml');
  if (!configFile.existsSync()) {
    throw const FileSystemException(
        "Expected path: build_scripts/config.yaml. Make sure your directory tree mathes this path");
  }

  final yamlContent = configFile.readAsStringSync();

  final yamlMap = loadYaml(yamlContent) as Map<dynamic, dynamic>;

  final flavorConfig = Flavors.fromYamlMap(yamlMap);
  Flavor flavor = flavorConfig.getFlavor(flavorName);

  processAssets(flavor.assetsToInclude, flowType);
  processClasses(flavor.name, flavor.classesToInclude, flowType);

  print("DONE");
}

const assetsPlaceHolder = "#flavor-script-placeholder do not remove this line.";
const beginTag = "#flavor-begin";
const endTag = "#flavor-end";
const listPlaceholder = "  #list-placeholder";
const assetsTemplate = """  $beginTag  
$listPlaceholder
  $endTag""";

void processAssets(List<String> assetsToInclude, FlowType flowType) {
  File pubspecFile = File("${Utils.parentPath}/pubspec.yaml");
  String fileContent = pubspecFile.readAsStringSync();
  if (flowType == FlowType.pre) {
    if (!fileContent.contains(assetsPlaceHolder)) {
      RegExp pattern = RegExp(r'#\s*assets:');
      if (fileContent.contains(pattern)) {
        fileContent =
            fileContent.replaceAll(pattern, "assets:\n$assetsPlaceHolder");
      } else {
        fileContent =
            fileContent.replaceAll("assets:", "assets:\n$assetsPlaceHolder");
      }
    }

    String outputString = assetsTemplate;
    for (String asset in assetsToInclude) {
      outputString = outputString.replaceFirst(
          listPlaceholder, "    - $asset\n$listPlaceholder");
    }
    outputString = outputString.replaceFirst(listPlaceholder, "");
    fileContent = fileContent.replaceFirst(assetsPlaceHolder, outputString);
  } else {
    RegExp pattern =
        RegExp(r'#flavor-begin(.*?)#flavor-end', multiLine: true, dotAll: true);
    fileContent = fileContent.replaceFirst(pattern, assetsPlaceHolder);
  }
  pubspecFile.writeAsStringSync(fileContent);
}

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
          "${annotationTemplate.replaceFirst("@", flavorName)}\n$startFileContent";
    }

    if (flowType == FlowType.pre && !destFileContent.contains(annotation)) {
      destFileContent =
          "${annotationTemplate.replaceFirst("@", "DEFAULT")}\n//  YOU CAN LEAVE THIS ONE EMPTY.\n$destFileContent";
    }

    startFile.writeAsStringSync(destFileContent);
    destFile.writeAsStringSync(startFileContent);

    print("Moving ${startFile.path} into ${destFile.path}");
    print("Moving ${destFile.path} into ${startFile.path}");
  }
}

const cwd = ".";
const annotation = """//  ###FLAVOR:""";
const annotationTemplate = """//  ###FLAVOR: @###""";

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
