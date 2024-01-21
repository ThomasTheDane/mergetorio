import 'dart:convert';
import 'dart:html';
import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:mergetorio/main.dart';
import 'package:mergetorio/util/util.dart';

import 'components/inventory.dart';
import 'components/gameGrid.dart';
import 'components/buildings.dart';
import 'components/store.dart';
import 'util/enums.dart';

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

  int gameStartTime = 0;
  String gameSaveId = "1";
  int lastSaveTime = 0;

  final world = World();
  late final CameraComponent cameraComponent;

  MergetorioGame(this.inventory, this.detailsModel, this.store) {
    gameGrid = GameGrid();
    gameStartTime = DateTime.now().millisecondsSinceEpoch;
    lastSaveTime = DateTime.now().millisecondsSinceEpoch;
    commandCenter = CommandCenter(BuildingSpec.command, Vector2(0, 0));

    detailsModel.updateBuilding(commandCenter);
  }

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: world);
    addAll([cameraComponent, world]);

    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    world.add(gameGrid);
    world.add(commandCenter);

    setupTesting();
  }

  bool didLoad = false;
  @override
  void update(double dt) {
    ///autoload
    if (!didLoad) {
      // didLoad = true;
      // loadGame(gameSaveId);
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastSaveTime > Duration(seconds: 5).inMilliseconds) {
      //need to autosave
      // saveCurrentGame();
      // lastSaveTime = currentTime;
    }

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
    // var mine = Mine(BuildingSpec.ironOreMine, Vector2(1, 1));
    // world.add(mine);
    // var mine2 = Mine(BuildingSpec.ironOreMine, Vector2(1, 2));
    // world.add(mine2);
    // var lab1 = Factory(BuildingSpec.science1Lab, Vector2(1, 0));
    // world.add(lab1);
    // var fac = Factory(BuildingSpec.ironOreMine, Vector2(3, 3));
    // world.add(fac);
    // var fac2 = Factory(BuildingSpec.ironOreMine, Vector2(4, 4));
    // world.add(fac2);

    // mines.addAll([mine, mine2]);
    // factories.add(lab1);
    inventory.testingSetup();

    // factories.add(fac2);
    // saveCurrentGame();
  }

  final Storage _localStorage = window.localStorage;
  saveCurrentGame() {
    Map<String, dynamic> savingJson = {};

    //Mergetorio game
    ////Game Data
    ////currently selected building in details
    //Inventory
    savingJson['"inventory"'] = inventory.toJson();

    //GameGrid
    savingJson['"gameGrid"'] = gameGrid.toJson();

    //Buildings
    Map<String, dynamic> buildingsJson = {};

    ///Command
    buildingsJson['"commandCenter"'] = commandCenter.toJson();
    ////Mines
    buildingsJson['"mines"'] = List.generate(mines.length, (i) {
      return mines[i].toJson();
    });
    ////Factories
    buildingsJson['"factories"'] = List.generate(factories.length, (i) {
      return factories[i].toJson();
    });
    savingJson['"buildings"'] = buildingsJson;

    //tech tree
    savingJson['"boughtUpgrades"'] = [];
    for (var element in store.boughtUpgrades) {
      savingJson['"boughtUpgrades"'].add('"${element.toString()}"');
    }

    savingJson['"purchaseLevels"'] = {};
    store.purchaseLevel.forEach((key, value) {
      savingJson['"purchaseLevels"']['"${key.toString().split('.').last}"'] =
          '"$value"';
    });

    savingJson['"timeAtSaving"'] = DateTime.now().millisecondsSinceEpoch;
    // store.boughtUpgrades.forEach((key, value) {
    //   savingJson['"boughtUpgrades"']['"${key.toString().split('.').last}"'] =
    //       '"$value"';
    // });

    //   materials.forEach((key, value) {
    // returnedJson['"materials"']['"${key.toString().split('.').last}"'] =
    //     '"$value"';

    //actually save
    print("========= saving Game ==========");
    // print(savingJson);

    saveGameState(gameSaveId, savingJson);
  }

  Future saveGameState(String gameId, Map<String, dynamic> gameState) async {
    print("Saving Game state: $gameState in ID: $gameId");
    _localStorage[gameSaveId] = gameState.toString();
    // _localStorage[gameId] = gameState;
  }

  loadGame(String gameId) async {
    String storedString = await getGameState(gameId);
    if (storedString == "No Data") {
      return;
    }

    Map<String, dynamic> storedGame =
        jsonDecode(storedString) as Map<String, dynamic>;
    print("Loading Game State: $storedString");

    //update inventory
    var materialsJson = storedGame["inventory"]["materials"];
    for (final aMaterial in materialsJson.keys) {
      // print("A materail $aMaterial set to ${materialsJson[aMaterial]}");
      inventory.materials[
              Material.values.byName(aMaterial.toString().split('.').last)] =
          double.parse(materialsJson[aMaterial]);
    }

    //destroy and remake gameGrid
    gameGrid.destroy();
    gameGrid = GameGrid.fromJson(storedGame["gameGrid"]);
    world.add(gameGrid);

    //tech tree
    for (final anUpgrade in storedGame["boughtUpgrades"]) {
      TechUpgrade storedUpgrade =
          TechUpgrade.values.byName(anUpgrade.split(".").last);
      if (!store.boughtUpgrades.contains(storedUpgrade)) {
        // store.handleTechUpgrade(storedUpgrade);
        store.boughtUpgrades.add(storedUpgrade);
      }
    }
    // for (final purchaseLevel in storedGame["purchaseLevels"]) {
    for (final purchaseLevel in storedGame["purchaseLevels"].keys) {
      store.purchaseLevel[BuildingSpec.values
              .byName(purchaseLevel.toString().split(".").last)] =
          int.parse(storedGame["purchaseLevels"][purchaseLevel]);
    }

    //update buildings
    commandCenter.destroy();
    commandCenter =
        CommandCenter.fromJson(storedGame["buildings"]["commandCenter"]);
    world.add(commandCenter);

    ////wipe all buildings #killAllRobots
    destroyAllBuildings();

    ////mines
    for (final aMineJson in storedGame["buildings"]["mines"]) {
      // print("placing mine: $aMineJson");
      var mine = Mine.fromJson(aMineJson);
      mines.add(mine);
      world.add(mine);
    }

    ////factories
    for (final aFactoryJson in storedGame["buildings"]["factories"]) {
      // print("placing factory: $aFactoryJson");
      var factory = Factory.fromJson(aFactoryJson);
      factories.add(factory);
      // world.add(factory);
    }
    await addAll(factories);

    print("finished adding factories");

    //run through the time
    if (storedGame["timeAtSaving"] != null) {
      double timeSinceSave = DateTime.now().millisecondsSinceEpoch -
          storedGame["timeAtSaving"] as double;

      print(
          "Elapsed time since save: ${Duration(milliseconds: timeSinceSave as int).inSeconds.toString()} seconds which is ${Duration(milliseconds: timeSinceSave as int).inMinutes.toString()} minutes");
      update(timeSinceSave / 1000);
    }

    //update UI
    store.notifyListeners();
  }

  Future<String> getGameState(gameId) async =>
      _localStorage[gameId] ?? "No Data";

  Future deleteGameState(String gameId) async {
    _localStorage.remove(gameId);
  }

  debugClick() {
    print("game debug click 1");
    // gameGrid
    saveCurrentGame();
  }

  debugClick2() {
    print("game debug click 2");
    loadGame("1");
  }

  debugClick3() {
    print("game debug click 3");
    print("jumping forward a minute");
    update(60);
    // cameraComponent.moveBy(Vector2(10, 10));
  }

  destroyAllBuildings() {
    for (Mine aMine in mines) {
      aMine.destroy();
    }
    mines = [];
    for (Factory aFactory in factories) {
      aFactory.destroy();
    }
    factories = [];
  }
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
