import 'dart:convert';
import 'dart:html';
import 'dart:js_interop';
import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:mergetorio/main.dart';
import 'package:mergetorio/util/util.dart';
import 'package:path_provider/path_provider.dart';
import '../game.dart';

import 'buildings.dart';
import '../util/enums.dart';

class Store extends ChangeNotifier {
  List<BuildingSpec> availableBuildings = [];
  List<TechUpgrade> boughtUpgrades = [];

  // @HiveField(1)
  late MergetorioGame gameRef;

  Map<BuildingSpec, int> purchaseLevel = {};

  Store() {
    initializeStart();
  }

  initializeStart() {
    availableBuildings.addAll([
      BuildingSpec.ironOreMine,
      BuildingSpec.ironPlateFactory,
      BuildingSpec.ironGearFactory,
      BuildingSpec.science1Lab
      // BuildingSpec.steelFactory
    ]);
    for (BuildingSpec aSpec in BuildingSpec.values) {
      purchaseLevel[aSpec] = 0;
    }
    purchaseLevel.remove(BuildingSpec.command);
    purchaseLevel[BuildingSpec.ironOreMine] = 1;
    boughtUpgrades.add(TechUpgrade.ironOreMine);
    purchaseLevel[BuildingSpec.ironPlateFactory] = 1;
    boughtUpgrades.add(TechUpgrade.ironPlateFactory);
    purchaseLevel[BuildingSpec.ironGearFactory] = 1;
    boughtUpgrades.add(TechUpgrade.ironGearFactory);
    purchaseLevel[BuildingSpec.science1Lab] = 1;
    boughtUpgrades.add(TechUpgrade.science1Lab);
  }

  mutliplyOutInitialResearchCosts(int lengthMul, int amountMult) {
    for (BuildingSpec aSpec in BuildingSpec.values) {
      for (int i = 0; i < lengthMul; i++) {}
    }
  }

  handleBuy(toBuySpec) {
    if (gameRef.inventory.checkIfCanSubtract(toBuySpec.cost,
        multiplier: purchaseLevel[toBuySpec])) {
      gameRef.inventory.subtractItems(toBuySpec.cost,
          multiplier: pow(2, purchaseLevel[toBuySpec]! - 1));
      if (toBuySpec.type == BuildingType.mine) {
        var newMine = Mine(
            toBuySpec, gameRef.gameGrid.getRandomUnoccupiedTile().gridPoint);
        newMine.level = purchaseLevel[toBuySpec] ?? 1;
        gameRef.add(newMine);
        gameRef.mines.add(newMine);
      }
      if (toBuySpec.type == BuildingType.factory) {
        var newFac = Factory(
            toBuySpec, gameRef.gameGrid.getRandomUnoccupiedTile().gridPoint);
        newFac.level = purchaseLevel[toBuySpec] ?? 1;
        gameRef.add(newFac);
        gameRef.factories.add(newFac);
      }
      if (toBuySpec.type == BuildingType.lab) {
        var newLab = Factory(
            toBuySpec, gameRef.gameGrid.getRandomUnoccupiedTile().gridPoint);
        gameRef.add(newLab);
        newLab.level = purchaseLevel[toBuySpec] ?? 1;
        gameRef.factories.add(newLab);
      }
    } else {
      print("too poor bitch");
    }
  }

  handleTechBuildingBuy(BuildingSpec toBuySpec) {
    //todo pickup it seems when a colum tech item disappears it still trigers that spot with the old spec
    if (gameRef.inventory.checkIfCanSubtract(
        getCostOfUpgrade(toBuySpec, purchaseLevel[toBuySpec] ?? 0))) {
      gameRef.inventory.subtractItems(
          getCostOfUpgrade(toBuySpec, purchaseLevel[toBuySpec] ?? 0));
      purchaseLevel[toBuySpec] = (purchaseLevel[toBuySpec] ?? 0) + 1;
    } else {
      print("too poor for tech bitch");
    }
    notifyListeners();
  }

  handleTechUpgrade(TechUpgrade upgrade) {
    bool done = false;
    print("Handling tech upgrade $upgrade");
    if (!gameRef.inventory.checkIfCanSubtract(upgrade.cost)) {
      print("too poor to upgrade (bitch)!");
      return;
    }
    gameRef.inventory.subtractItems(upgrade.cost);
    boughtUpgrades.add(upgrade);

    //special upgrades
    if (upgrade == TechUpgrade.expand1) {
      gameRef.gameGrid.growGridRight();
      gameRef.gameGrid.growGridDown();
      gameRef.gameGrid.resizeAndLayout();
      done = true;
    }
    notifyListeners();

    if (done) {
      print("research done after special");
      return;
    }

    //building upgrades
    // if (!BuildingSpec.values.contains(upgrade.toString().split(".").last)) {
    //   print("building spec not found");
    //   return;
    // }

    BuildingSpec toUnlockSpec =
        BuildingSpec.values.byName(upgrade.toString().split(".").last);
    print("unlocking $toUnlockSpec");
    purchaseLevel[toUnlockSpec] = 1;
    // boughtUpgrades.add(upgrade);
  }

  Map<Material, double> getCostOfUpgrade(
      BuildingSpec aSpec, int upgradingToLevel) {
    Map<Material, double> costs = {};
    // for (Material aCost in aSpec.researchCost.keys) {
    for (Material aCost in TechUpgrade.values
        .byName(aSpec.toString().split(".").last)
        .cost
        .keys) {
      costs[aCost] = (TechUpgrade.values
                  .byName(aSpec.toString().split(".").last)
                  .cost[aCost] ??
              0) *
          pow(2, upgradingToLevel);
      // (aSpec.researchCost[aCost] ?? 0) * pow(2, upgradingToLevel);
    }
    return costs;
  }
}
