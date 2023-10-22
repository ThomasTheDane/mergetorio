import 'dart:convert';
import 'dart:html';
import 'dart:js_interop';
import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:mergetorio/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import 'components/buildings.dart';
import 'components/tiles.dart';
import '../../game.dart';

part 'game.g.dart';

@HiveType(typeId: 0)
class MergetorioGame extends FlameGame {
  @HiveField(0)
  late Inventory inventory;
  @HiveField(1)
  late Store store;
  @HiveField(2)
  late DetailsModel detailsModel;
  @HiveField(3)
  late GameGrid gameGrid;

  bool isDragging = false;
  Building? dragTarget;

  late CommandCenter commandCenter;
  List<Mine> mines = [];
  List<Factory> factories = [];

  String gameSaveId = "1";

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

    registerAdapters();

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
    inventory.testingSetup();

    // factories.add(fac2);
    // saveCurrentGame();
  }

  registerAdapters() {
    Hive.registerAdapter(MergetorioGameAdapter());
    Hive.registerAdapter(MaterialAdapter());
    Hive.registerAdapter(InventoryAdapter());
    Hive.registerAdapter(GameGridAdapter());
    Hive.registerAdapter(TileAdapter());
    Hive.registerAdapter(StoreAdapter());
    Hive.registerAdapter(BuildingSpecAdapter());
    Hive.registerAdapter(DetailsModelAdapter());
    Hive.registerAdapter(BuildingTypeAdapter());
    Hive.registerAdapter(BuildingAdapter());
    Hive.registerAdapter(CommandCenterAdapter());
    Hive.registerAdapter(FactoryAdapter());
    Hive.registerAdapter(MineAdapter());
  }

  saveCurrentGame() async {
    var box = await Hive.openBox('game1');

    box.put('inventory', inventory);

    // Hive.close();
  }

  loadGame() async {
    var box = await Hive.openBox('game1');

    var retrivedInventory = box.get('inventory');
    print("retrived: $retrivedInventory");
    if (retrivedInventory != null) {
      inventory = box.get('inventory');
      // print(test);

      // inventory.materials = retrived as Map<Material, double>;
    }
  }

  // saveCurrentGame() {
  //   Map<String, dynamic> savingJson = {};

  //   //Mergetorio game
  //   ////Game Data
  //   ////currently selected building in details
  //   //Inventory
  //   savingJson["inventory"] = inventory.toJson();
  //   print(savingJson);

  //   //GameGrid
  //   ////Gridsize
  //   ////GridMapOfTiles

  //   //Buildings

  //   //actually save
  //   print("========= saving Game ==========");
  //   print(savingJson);

  //   saveGameState(gameSaveId, savingJson);
  // }

  // Future saveGameState(String gameId, Map<String, dynamic> gameState) async {
  //   // print("Saving Game state: $gameState in ID: $gameId");
  //   _localStorage['inventory'] = gameState.toString();
  //   // _localStorage[gameId] = gameState;
  // }

  // loadGame(String gameId) async {
  //   String storedString =
  //       _convertToJsonStringQuotes(await getGameState(gameId));
  //   //remove second to last character
  //   storedString = storedString.substring(0, storedString.length - 2) +
  //       storedString.substring(storedString.length - 1, storedString.length);
  //   print("Loading Game State: $storedString");

  //   Map<String, dynamic> storedGame =
  //       jsonDecode(storedString) as Map<String, dynamic>;
  //   //update inventory
  //   print(storedGame["inventory"]["materials"]);
  //   print(inventory.materials);
  //   Map<Material, double> storedMaterials =
  //       storedGame["inventory"]["materials"] as Map<Material, double>;
  //   // inventory.materials =
  //   // storedGame["inventory"]["materials"] as Map<Material, double>;
  // }

  // final Storage _localStorage = window.localStorage;

  // Future<String> getGameState(gameId) async =>
  //     _localStorage["inventory"] ?? "No Data";

  // Future deleteGameState(String gameId) async {
  //   _localStorage.remove(gameId);
  // }

  debugClick() {
    print("game debug click 1");
    saveCurrentGame();
  }

  debugClick2() {
    print("game debug click 2");
    loadGame();
    // loadGame("1");
  }

  // String _convertToJsonStringQuotes(String jsonString) {
  //   /// add quotes to json string
  //   jsonString = jsonString.replaceAll('{', '{"');
  //   jsonString = jsonString.replaceAll(': ', '": "');
  //   jsonString = jsonString.replaceAll(', ', '", "');
  //   jsonString = jsonString.replaceAll('}', '"}');

  //   /// remove quotes on object json string
  //   jsonString = jsonString.replaceAll('"{"', '{"');
  //   jsonString = jsonString.replaceAll('"}"', '"}');

  //   /// remove quotes on array json string
  //   jsonString = jsonString.replaceAll('"[{', '[{');
  //   jsonString = jsonString.replaceAll('}]"', '}]');

  //   return jsonString;
  // }
}

@HiveType(typeId: 6)
class GameGrid extends Component with HasGameRef<MergetorioGame> {
  @HiveField(0)
  List<List<Tile>> tiles = [[]];
  @HiveField(1)
  int gridWidth = 5;
  @HiveField(2)
  int gridHeight = 5;
  @HiveField(3)
  double gridPixelSize = 1000;
  @HiveField(4)
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

@HiveType(typeId: 1)
class Inventory extends ChangeNotifier {
  // @HiveField(0)
  late MergetorioGame gameRef;

  @HiveField(0)
  Map<Material, double> materials = <Material, double>{};
  @HiveField(1)
  Map<Material, double> rates = <Material, double>{};

  Inventory() {}

  testingSetup() {
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

  Map<String, dynamic> toJson() => {'materials': materials};
}

@HiveType(typeId: 3)
class Store extends ChangeNotifier {
  @HiveField(0)
  List<BuildingSpec> availableBuildings = [];

  // @HiveField(1)
  late MergetorioGame gameRef;

  @HiveField(1)
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
        getCostOfUpgrade(toBuySpec, purchaseLevel[toBuySpec] ?? 0))) {
      gameRef.inventory.subtractItems(
          getCostOfUpgrade(toBuySpec, purchaseLevel[toBuySpec] ?? 0));
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

@HiveType(typeId: 2)
enum Material {
  @HiveField(0)
  dirt,
  @HiveField(1)
  ironOre,
  @HiveField(2)
  ironPlate,
  @HiveField(3)
  ironGear,
  @HiveField(4)
  science1,

  @HiveField(5)
  engine,
  @HiveField(6)
  copperOre,
  @HiveField(7)
  copperPlate,
  @HiveField(8)
  copperCable,
  @HiveField(9)
  greenCircuit,
  @HiveField(10)
  science2,

  @HiveField(11)
  oil,
  @HiveField(12)
  petroleum,
  @HiveField(13)
  lightOil,
  @HiveField(14)
  heavyOil,

  @HiveField(15)
  coal,
  @HiveField(16)
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

@HiveType(typeId: 4)
enum BuildingSpec {
  @HiveField(0)
  command(
      type: BuildingType.special,
      cost: {},
      recipe: Recipe.empty,
      researchCost: {}),
  @HiveField(1)
  ironOreMine(
      type: BuildingType.mine,
      cost: {Material.ironOre: 10},
      recipe: Recipe.ironOre,
      researchCost: {Material.science1: 10}),
  @HiveField(2)
  ironPlateFactory(
      type: BuildingType.factory,
      cost: {Material.ironOre: 20},
      recipe: Recipe.ironPlate,
      researchCost: {Material.science1: 15}),
  @HiveField(3)
  ironGearFactory(
      type: BuildingType.factory,
      cost: {Material.ironPlate: 10},
      recipe: Recipe.ironGear,
      researchCost: {Material.science1: 20}),
  @HiveField(4)
  science1Lab(
      type: BuildingType.lab,
      cost: {Material.ironGear: 10},
      recipe: Recipe.science1,
      researchCost: {Material.science1: 40}),
  @HiveField(5)
  copperPlateFactory(
      type: BuildingType.factory,
      cost: {Material.copperOre: 20},
      recipe: Recipe.copperPlate,
      researchCost: {Material.science1: 50}),
  @HiveField(6)
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

@HiveType(typeId: 5)
class DetailsModel extends ChangeNotifier {
  @HiveField(0)
  Building? selectedBuilding;

  DetailsModel() {
    // selectedBuilding = game.factories[0];
    // selectedBuilding = Mine(Game.Recipe.ironOre, Vector2(1, 1));
  }

  updateBuilding(newBuilding) {
    selectedBuilding = newBuilding;
    print("showing new building in details view");
    print(newBuilding);
    notifyListeners();
  }

  pauseClick() {
    if (selectedBuilding?.paused ?? false) {
      selectedBuilding?.paused = false;
      print('playing building');
    } else {
      print('pausing building');
      selectedBuilding?.paused = true;
    }
    notifyListeners();
  }

  refundClick() {
    print('refund!');
    inventoryModel.addItems(selectedBuilding!.buildingSpec.cost,
        multiplier: pow(
            2, game.store.purchaseLevel[selectedBuilding!.buildingSpec]! - 1));
    inventoryModel.addItems(selectedBuilding!.buildingSpec.recipe.cost,
        multiplier: pow(
            2, game.store.purchaseLevel[selectedBuilding!.buildingSpec]! - 1));
    selectedBuilding?.placedOnTile.buildingPlacedOn = null;
    game.remove(selectedBuilding!);

    if (selectedBuilding is Factory) {
      game.factories.remove(selectedBuilding);
    }
    if (selectedBuilding is Mine) {
      game.mines.remove(selectedBuilding);
    }

    // todo : alert if refund will hit storage limit
  }
}
