import 'dart:convert';
import 'dart:html';
import 'dart:js_interop';
import 'dart:math';

import 'package:flame/flame.dart';
// import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:mergetorio/main.dart';
import 'package:mergetorio/util/util.dart';
import 'package:path_provider/path_provider.dart';

import 'buildings.dart';
import 'tiles.dart';
import '../game.dart';
import '../../game.dart';
import '../util/enums.dart';

class Inventory extends ChangeNotifier {
  // @HiveField(0)
  late MergetorioGame gameRef;

  Map<Material, double> materials = <Material, double>{};
  Map<Material, double> rates = <Material, double>{};

  Inventory() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> returnedJson = {};
    returnedJson['"materials"'] = {};
    materials.forEach((key, value) {
      returnedJson['"materials"']['"${key.toString().split('.').last}"'] =
          '"$value"';
    });

    return returnedJson;
  } //=> {'"materials"': materials};

  testingSetup() {
    materials[Material.ironOre] = 100;
    // materials[Material.ironPlate] = 100;
    materials[Material.ironGear] = 100;
    // materials[Material.coal] = 100;
    materials[Material.science1] = 100;
  }

  addItems(Map<Material, double> additions, {multiplier = 1}) {
    multiplier = multiplier ?? 1;
    //check if any of them are new
    additions.forEach((aMaterial, anAmount) {
      if (!materials.containsKey(aMaterial)) {
        addNewMaterial(aMaterial);

        print("new material \\o/ ");
      }
      materials[aMaterial] =
          (materials[aMaterial] ?? 0) + (anAmount * multiplier);
    });
    notifyListeners();
  }

  addItem(Material aMaterial, double anAmount, {multiplier = 1}) {
    // multiplier = multiplier ?? 1;
    if (!materials.containsKey(aMaterial)) {
      addNewMaterial(aMaterial);

      print("new material \\o/ ");
    }
    materials[aMaterial] =
        (materials[aMaterial] ?? 0) + (anAmount * multiplier);

    notifyListeners();
  }

  subtractItems(Map<Material, double> subtractions, {multiplier = 1}) {
    // multiplier = multiplier ?? 1;
    subtractions.forEach((key, value) {
      materials[key] = (materials[key] ?? 0) - (value * multiplier);
    });
    notifyListeners();
  }

  checkIfCanAdd(Map<Material, double> additions) {
    return true; //todo check against storage limits once implemented
  }

  bool checkIfCanSubtract(Map<Material, double> subtractions,
      {multiplier = 1}) {
    bool canSubtract = true;
    subtractions.forEach((key, value) {
      if (materials[key].isNull) {
        canSubtract = false;
      }
      if ((materials[key] ?? 0) - (value * multiplier) < 0) {
        canSubtract = false;
      }
    });

    return canSubtract;
  }

  addNewMaterial(aMaterial) {
    materials[aMaterial] = 0;
  }

  calcRates() {
    for (Material aMaterial in Material.values) {
      rates[aMaterial] = 0;
    }
    for (Mine aMine in game.mines) {
      if (aMine.placedOnTile.material != Material.dirt &&
          aMine.buildingSpec.recipe.products.keys
              .contains(aMine.placedOnTile.material) &&
          !aMine.paused) {
        rates[aMine.placedOnTile.material] =
            (rates[aMine.placedOnTile.material] ?? 0) +
                (aMine.level / aMine.buildingSpec.recipe.duration);
      }
    }

    for (Factory aFac in gameRef.factories) {
      if (aFac.crafting && !aFac.paused) {
        //add production items
        //todo: !waitingAtFull
        aFac.buildingSpec.recipe.products.forEach((key, value) {
          rates[key] = (rates[key] ?? 0) +
              (aFac.buildingSpec.recipe.products[key]! /
                  (aFac.buildingSpec.recipe.duration / aFac.level));
        });
        aFac.buildingSpec.recipe.cost.forEach((key, value) {
          rates[key] = (rates[key] ?? 0) -
              (aFac.buildingSpec.recipe.cost[key]! /
                  (aFac.buildingSpec.recipe.duration / aFac.level));
        });
      }
    }
    notifyListeners();
  }

  wipeInventory() {
    materials.forEach((key, value) {
      materials[key] = 0;
      //todo potentially remove the icons UI
    });
  }

  justNotify() {
    notifyListeners();
  }
}
