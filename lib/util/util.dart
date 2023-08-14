// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import '../game.dart';

export 'color_schemes.dart';
export 'num_utils.dart';
import '../components/buildings.dart';

prettyFormat(double? n) {
  n ??= 0;
  if (n < .000000001) {
    return "0";
  }
  if (n < 0 && n > -1) {
    return "-${n.toStringAsPrecision(2).substring(2)}";
  }
  if (n < 0.1 && n > 0) {
    return n.toStringAsPrecision(1);
  }

  if (n < 1) {
    return n.toStringAsPrecision(2);
  }
  return (n).toStringAsFixed(0);
  // return n.toStringAsFixed(n.toString());
  // var f = NumberFormat("###.0#", "en_US");
  // print(f.format(12.345));
}

String prettyNames(Material aMaterial) {
  if (aMaterial == Material.science1) {
    return "Science 1";
  }
  if (aMaterial == Material.science2) {
    return "Green Science";
  }

  return camelToSentence(aMaterial.toString().split('.').last);
}

String prettyBuildingNames(Building? aBuilding) {
  if (aBuilding is Mine) {
    return "${camelToSentence(aBuilding.buildingSpec.recipe.toString().split(".").last)} Mine";
  }
  if (aBuilding is Factory) {
    return "${camelToSentence(aBuilding.buildingSpec.recipe.toString().split(".").last)} Factory";
  }
  if (aBuilding is CommandCenter) {
    return "Command Center";
  }

  return "pretty not found";
}

String prettyBuildingSpecNames(BuildingSpec aBuildingSpec) {
  if (aBuildingSpec.type == BuildingType.mine) {
    return "${camelToSentence(aBuildingSpec.recipe.toString().split(".").last)} Mine";
  }
  if (aBuildingSpec.type == BuildingType.factory) {
    return "${camelToSentence(aBuildingSpec.recipe.toString().split(".").last)} Factory";
  }

  if (aBuildingSpec.type == BuildingType.lab) {
    return "${camelToSentence(aBuildingSpec.recipe.toString().split(".").last)} Lab";
  }

  return "pretty not found";
}

String camelToSentence(String text) {
  var result = text.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), r" ");
  var finalResult = result[0].toUpperCase() + result.substring(1);
  return finalResult;
}
