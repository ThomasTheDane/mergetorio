import 'dart:html';
import 'dart:js_interop';
import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:mergetorio/main.dart';

import 'components/buildings.dart';
import 'components/tiles.dart';
import '../../game.dart';

class MergetorioGame extends FlameGame {
  late Inventory inventory;
  late Store store;
  late DetailsModel detailsModel;
  late GameGrid gameGrid;

  bool isDragging = false;
  Building? dragTarget;

  late CommandCenter commandCenter;
  List<Mine> mines = [];
  List<Factory> factories = [];

  MergetorioGame(this.inventory, this.detailsModel, this.store) {
    gameGrid = GameGrid();
    commandCenter = CommandCenter(BuildingSpec.command, Vector2(2, 2));
    add(commandCenter);

    detailsModel.updateBuilding(commandCenter);
  }

  @override
  Future<void> onLoad() async {
    final world = World();
    add(world);
    // add(aTile);

    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize = Vector2(1000, 1000)
      ..viewfinder.anchor = Anchor.topLeft;
    add(camera);

    add(gameGrid);

    setupTesting();
  }

  // void test() {
  // print(inventory.materials);
  // inventory.justNotify();
  // }

  @override
  void update(double dt) {
    double coarseness = 0.05;
    if (dt > coarseness) {
      print("Timne passed $dt more than $coarseness passed, splitting up");
      int runtimes = (dt / coarseness).floor();
      for (int i = 0; i < runtimes; i++) {
        for (final aProducer in mines) {
          aProducer.productionIncrement(dt / runtimes);
        }
        for (final aProducer in factories) {
          aProducer.productionIncrement(dt / runtimes);
        }
      }
    } else {
      for (final aProducer in mines) {
        aProducer.productionIncrement(dt);
      }
      for (final aProducer in factories) {
        aProducer.productionIncrement(dt);
      }
    }
    inventory.calcRates();
    super.update(dt);
  }

  setupTesting() {
    var mine = Mine(BuildingSpec.ironOreMine, Vector2(1, 1));
    add(mine);
    var mine2 = Mine(BuildingSpec.ironOreMine, Vector2(1, 2));
    add(mine2);
    var lab1 = Factory(BuildingSpec.science1Lab, Vector2(0, 0));
    add(lab1);
    // var fac = Factory(BuildingSpec.ironOreMine, Vector2(3, 3));
    // add(fac);
    // var fac2 = Factory(BuildingSpec.ironOreMine, Vector2(4, 4));
    // add(fac2);

    mines.addAll([mine, mine2]);
    factories.add(lab1);
    // factories.add(fac2);
  }
}

class GameGrid extends Component with HasGameRef<MergetorioGame> {
  List<List<Tile>> tiles = [[]];
  int gridWidth = 5;
  int gridHeight = 5;
  double gridPixelSize = 1000;
  double tilePixelSize = 200;

  GameGrid() {}

  @override
  Future<void> onLoad() async {
    gridPixelSize = gameRef.size.x;
    tilePixelSize = gridPixelSize / gridWidth;
    _generateTiles();
  }

  _generateTiles() {
    tiles = List.generate(
        gridHeight,
        (y) => List.generate(gridWidth, (x) {
              Tile aTile =
                  Tile(Material.dirt, Vector2(x.toDouble(), y.toDouble()));
              if (x == 1 && y == 1) {
                aTile =
                    Tile(Material.ironOre, Vector2(x.toDouble(), y.toDouble()));
              }
              gameRef.add(aTile);
              return aTile;
            }, growable: true),
        growable: true);
  }

  Tile getRandomUnoccupiedTile() {
    Random random = Random();

    while (true) {
      //todo: breakout detection
      int randX = random.nextInt(gridWidth);
      int randY = random.nextInt(gridHeight);
      if (tiles[randY][randX].buildingPlacedOn == null) {
        return tiles[randY][randX];
      }
    }
  }
}

class Inventory extends ChangeNotifier {
  late MergetorioGame gameRef;

  Map<Material, double> materials = <Material, double>{};
  Map<Material, double> rates = <Material, double>{};

  Inventory() {
    materials[Material.ironOre] = 100;
    materials[Material.ironPlate] = 100;
    materials[Material.ironGear] = 100;
    materials[Material.coal] = 100;
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

  justNotify() {
    notifyListeners();
  }
}

class Store extends ChangeNotifier {
  List<BuildingSpec> availableBuildings = [];
  late MergetorioGame gameRef;
  Map<BuildingSpec, int> purchaseLevel = {};

  Store() {
    initializeStart();
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
    purchaseLevel[BuildingSpec.ironPlateFactory] = 1;
    purchaseLevel[BuildingSpec.ironGearFactory] = 1;
    purchaseLevel[BuildingSpec.science1Lab] = 1;
  }

  mutliplyOutInitialResearchCosts(int lengthMul, int amountMult) {
    for (BuildingSpec aSpec in BuildingSpec.values) {
      for (int i = 0; i < lengthMul; i++) {}
    }
  }

  handleTechBuildingBuy(BuildingSpec toBuySpec) {
    //todo pickup it seems when a colum tech item disappears it still trigers that spot with the old spec
    if (gameRef.inventory.checkIfCanSubtract(
        getCostOfUpgrade(toBuySpec, purchaseLevel[toBuySpec] ?? 0),
        multiplier: pow(2, purchaseLevel[toBuySpec]! - 1))) {
      gameRef.inventory.subtractItems(
          getCostOfUpgrade(toBuySpec, purchaseLevel[toBuySpec] ?? 0),
          multiplier: pow(2, purchaseLevel[toBuySpec]! - 1));
      purchaseLevel[toBuySpec] = (purchaseLevel[toBuySpec] ?? 0) + 1;
    } else {
      print("too poor for tech bitch");
    }
    notifyListeners();
  }

  Map<Material, double> getCostOfUpgrade(
      BuildingSpec aSpec, int upgradingToLevel) {
    Map<Material, double> costs = {};
    for (Material aCost in aSpec.researchCost.keys) {
      costs[aCost] =
          (aSpec.researchCost[aCost] ?? 0) * pow(2, upgradingToLevel);
    }
    return costs;
  }
}

// copperCable: { products: { copperCable: 1 }, costs: { copperPlate: 2 }, duration: 4 },
//
// engine: { products: { engine: 1 }, costs: { ironPlate: 4, ironGear: 2}, duration: 8 },
// greenCircuit: { products: { greenCircuit: 1 }, costs: { copperPlate: 2, copperCable: 1 }, duration: 5 },

// oilProcessing1: { products: { petroleum: 1 }, costs: { oil: 5 }, duration: 5 },

// steel: { products: { steel: 1 }, costs: { ironPlate:  2, coal: 4}, duration: 5 },
// plastic: { products: { plastic: 1 }, costs: { petroleum:  2, coal: 2}, duration: 5 },
// redCircuit: { products: { redCircuit: 1 }, costs: { greenCircuit:  5, plastic: 2}, duration: 5 },

// oilProcessing2: { products: { petroleum: 1, lightOil: 1, heavyOil: 2 }, costs: { oil: 10 }, duration: 6 },
// heavyOilBreakdown: { products: { petroleum: 2, lightOil: 4 }, costs: { heavyOil: 3 }, duration: 3 },
// lightOilBreakdown: { products: { petroleum: 6 }, costs: { lightOil: 4 }, duration: 3 },

// solidFuel1: { products: { solidFuel: 1 }, costs: { petroleum: 10 }, duration: 4 },
// solidFuel2: { products: { solidFuel: 1 }, costs: { lightOil: 5 }, duration: 4 },
// solidFuel3: { products: { solidFuel: 1 }, costs: { heavyOil: 3 }, duration: 4 },
// rocketFuel: { products: { solidFuel: 1 }, costs: { lightOil: 4, solidFuel: 10 }, duration: 6 },

// purpleCircuit: { products: { purpleCircuit: 1 }, costs: { redCircuit: 2, greenCircuit: 10 }, duration: 10 },
// lowDensityStructure: { products: { lowDensityStructure: 1 }, costs: { steel: 5, plastic: 10, copperPlate: 20 }, duration: 10 },

// rocketPart: { products: { rocketPart: 1 }, costs: { rocketFuel: 1, lowDensityStructure: 1,  purpleCircuit: 1}, duration: 20 },

// science1: { products: { science1: 1 }, costs: { ironGear: 2, ironPlate: 5 }, duration: 5},
// science2: { products: { science2: 1 }, costs: { engine: 2, greenCircuit: 1 }, duration: 10},
// science3: { products: { science3: 1 }, costs: { steel: 5, redCircuit: 2 }, duration: 20},
// science4: { products: { science4: 1 }, costs: { rocketFuel: 5, purpleCircuit: 2,  }, duration: 20},

enum Material {
  dirt,
  ironOre,
  ironPlate,
  ironGear,
  science1,

  engine,
  copperOre,
  copperPlate,
  copperCable,
  greenCircuit,
  science2,

  oil,
  petroleum,
  lightOil,
  heavyOil,

  coal,
  steel
}

enum Recipe {
  empty(cost: {}, products: {}, duration: 1),
  ironOre(cost: {}, products: {Material.ironOre: 1}, duration: 1),
  copperOre(cost: {}, products: {Material.ironOre: 1}, duration: 1),
  ironPlate(
      cost: {Material.ironOre: 10},
      products: {Material.ironPlate: 1},
      duration: 10),
  ironGear(
      cost: {Material.ironPlate: 10},
      products: {Material.ironGear: 1},
      duration: 20),
  science1(
      cost: {Material.ironPlate: 10, Material.ironGear: 5},
      products: {Material.science1: 1},
      duration: 30),
  copperPlate(
      cost: {Material.copperOre: 10},
      products: {Material.copperPlate: 1},
      duration: 10),
  steel(
      cost: {Material.ironOre: 10, Material.coal: 1},
      products: {Material.steel: 1},
      duration: 20);

  const Recipe(
      {required this.cost, required this.products, required this.duration});

  final Map<Material, double> cost;
  final Map<Material, double> products;
  final double duration;
}

enum BuildingSpec {
  command(
      type: BuildingType.special,
      cost: {},
      recipe: Recipe.empty,
      researchCost: {}),
  ironOreMine(
      type: BuildingType.mine,
      cost: {Material.ironOre: 10},
      recipe: Recipe.ironOre,
      researchCost: {Material.science1: 10}),
  ironPlateFactory(
      type: BuildingType.factory,
      cost: {Material.ironOre: 20},
      recipe: Recipe.ironPlate,
      researchCost: {Material.science1: 15}),
  ironGearFactory(
      type: BuildingType.factory,
      cost: {Material.ironPlate: 10},
      recipe: Recipe.ironGear,
      researchCost: {Material.science1: 20}),
  science1Lab(
      type: BuildingType.lab,
      cost: {Material.ironGear: 10},
      recipe: Recipe.science1,
      researchCost: {Material.science1: 40}),
  copperPlateFactory(
      type: BuildingType.factory,
      cost: {Material.copperOre: 20},
      recipe: Recipe.copperPlate,
      researchCost: {Material.science1: 50}),
  steelPlateFactory(
      type: BuildingType.factory,
      cost: {Material.coal: 10},
      recipe: Recipe.steel,
      researchCost: {Material.science1: 100});

  const BuildingSpec(
      {required this.type,
      required this.cost,
      required this.recipe,
      required this.researchCost});

  final BuildingType type;
  final Map<Material, double> cost;
  final Recipe recipe;
  final Map<Material, double> researchCost;
}

// class Research {
//   late MergetorioGame gameRef;
//   Map<TechUpgrade, Function> techUpgradeEnactFunctions =
//       <TechUpgrade, Function>{};
//   // Map<BuildingSpec, List<Material>> buildingResearchCosts
//   // List<BuildingSpec> availableBuildingTech = [];

//   // List<TechItem> availableTech = [];

//   Research() {
//     setupUnlockBuildingResearch();
//   }

//   handleBuildingUnlockClick(toUnlockSpec) {
//     gameRef.store.availableBuildings.add(toUnlockSpec);
//   }

//   setupUnlockBuildingResearch() {
//     // print('setting up unlocking research specs');
//     for (BuildingSpec aSpec in BuildingSpec.values) {
//       // if (!gameRef.store.availableBuildings.contains(aSpec)) {}

//       // TechItem newTech = TechItem(TechType.buildingUnlock);
//       // availableTech.add(newTech);
//     }
//   }

//   Map<Material, double> getCostOfUpgrade(
//       BuildingSpec aSpec, int upgradingToLevel) {
//     return {};
//   }
// }

// class TechItem {
//   TechType techType;
//   TechItem(this.techType){
//     if(techType == TechType.buildingUnlock){

//     }
//   }

//   void enact() {}
// }

// enum TechType { buildingUnlock, buildingUpgrade, upgrade }

enum TechUpgrade { expand1, expand2, clickHarder }
