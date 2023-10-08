// ignore_for_file: avoid_relative_lib_imports

import '../yaml-master/lib/yaml.dart';
import 'flavor.dart';

class Flavors {
  List<Flavor> flavors = [];

  Flavors();

  factory Flavors.fromYamlMap(Map<dynamic, dynamic> yamlMap) {
    final flavors = Flavors();

    if (!yamlMap.containsKey('flavors')) {
      throw const FormatException(
          "config.yaml file should contain property 'flavors'");
    }

    final flavorsMap = yamlMap['flavors'] as Map<dynamic, dynamic>;
    for (final MapEntry flavorEntry in flavorsMap.entries) {
      if (flavorEntry.value == null) {
        flavors.flavors.add(
          Flavor(name: flavorEntry.key),
        );
      } else {
        flavors.flavors.add(
          _parseFlavor(flavorEntry.key, flavorEntry.value),
        );
      }
    }

    return flavors;
  }

  static Flavor _parseFlavor(String flavorName, YamlList flavorData) {
    Flavor flavor = Flavor(name: flavorName);
    for (final item in flavorData.nodes) {
      String value = item.value as String;
      if (value.startsWith("assets")) {
        flavor.assetsToInclude.add(value);
      } else if (value.startsWith("lib")) {
        flavor.classesToInclude.add(value);
      }
    }
    return flavor;
  }

  Flavor getFlavor(String name) {
    for (Flavor flavor in flavors) {
      if (flavor.name == name) return flavor;
    }
    throw const FormatException("Flavor not found. Please (re-)run init.dart.");
  }
}
