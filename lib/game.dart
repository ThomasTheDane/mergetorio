import 'dart:js_interop';

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
  late GameGrid gameGrid;

  bool isDragging = false;
  Building? dragTarget;

  List<Mine> mines = [];
  List<Factory> factories = [];

  MergetorioGame(this.inventory) {
    gameGrid = GameGrid();
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
    for (final aProducer in mines) {
      aProducer.productionIncrement(dt);
    }
    for (final aProducer in factories) {
      aProducer.productionIncrement(dt);
    }
    super.update(dt);
  }

  setupTesting() {
    var mine = Mine(Material.ironOre, Vector2(1, 1));
    add(mine);
    var mine2 = Mine(Material.ironOre, Vector2(2, 2));
    add(mine2);
    var fac = Factory(Recipe.ironPlate, Vector2(3, 3));
    add(fac);
    var fac2 = Factory(Recipe.ironPlate, Vector2(4, 4));
    add(fac2);

    mines.addAll([mine, mine2]);
    factories.add(fac);
    factories.add(fac2);
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
}

class Inventory extends ChangeNotifier {
  var materials = <Material, double>{};

  Inventory() {
    materials[Material.ironOre] = 100;
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

  bool checkIfCanSubtract(Map<Material, double> additions, {multiplier = 1}) {
    bool canSubtract = true;
    additions.forEach((key, value) {
      if (materials[key].isNull) {
        canSubtract = false;
      }
      if (materials[key]! - (value * multiplier) < 0) {
        canSubtract = false;
      }
    });

    return canSubtract;
  }

  addNewMaterial(aMaterial) {
    materials[aMaterial] = 0;
    //todo add to inventory ui
  }

  justNotify() {
    notifyListeners();
  }
}

enum Material { dirt, ironOre, copperOre, ironPlate, copperPlate }

// ironPlate: { products: { ironPlate: 1 }, costs: { ironOre: 1 }, duration: 10 },
//         ironGear: { products: { ironGear: 1 }, costs: { ironPlate: 2 }, duration:  20},

//         copperPlate: { products: { copperPlate: 1 }, costs: { copperOre: 2 }, duration: 20 },
//         copperCable: { products: { copperCable: 1 }, costs: { copperPlate: 2 }, duration: 40 },

//         engine: { products: { engine: 1 }, costs: { ironPlate: 4, ironGear: 2}, duration: 80 },
//         greenCircuit: { products: { greenCircuit: 1 }, costs: { copperPlate: 2, copperCable: 1 }, duration: 50 },

//         oilProcessing1: { products: { petroleum: 1 }, costs: { oil: 5 }, duration: 50 },
//         // steel: { products: { steel: 1 }, costs: { ironPlate:  20, coal: 5}, duration: 5 },
//         // plastic: { products: { plastic: 1 }, costs: { petroleum:  50, coal: 4}, duration: 5 },
//         // redCircuit: { products: { redCircuit: 1 }, costs: { greenCircuit:  20, plastic: 5}, duration: 5 },

//         steel: { products: { steel: 1 }, costs: { ironPlate:  2, coal: 4}, duration: 50 },
//         plastic: { products: { plastic: 1 }, costs: { petroleum:  2, coal: 2}, duration: 50 },
//         redCircuit: { products: { redCircuit: 1 }, costs: { greenCircuit:  5, plastic: 2}, duration: 50 },

//         oilProcessing2: { products: { petroleum: 1, lightOil: 1, heavyOil: 2 }, costs: { oil: 10 }, duration: 60 },
//         heavyOilBreakdown: { products: { petroleum: 2, lightOil: 4 }, costs: { heavyOil: 3 }, duration: 30 },
//         lightOilBreakdown: { products: { petroleum: 6 }, costs: { lightOil: 4 }, duration: 30 },

//         solidFuel1: { products: { solidFuel: 1 }, costs: { petroleum: 10 }, duration: 40 },
//         solidFuel2: { products: { solidFuel: 1 }, costs: { lightOil: 5 }, duration: 40 },
//         solidFuel3: { products: { solidFuel: 1 }, costs: { heavyOil: 3 }, duration: 40 },
//         rocketFuel: { products: { solidFuel: 1 }, costs: { lightOil: 4, solidFuel: 10 }, duration: 60 },

//         purpleCircuit: { products: { purpleCircuit: 1 }, costs: { redCircuit: 2, greenCircuit: 10 }, duration: 100 },
//         lowDensityStructure: { products: { lowDensityStructure: 1 }, costs: { steel: 5, plastic: 10, copperPlate: 20 }, duration: 100 },

//         rocketPart: { products: { rocketPart: 1 }, costs: { rocketFuel: 1, lowDensityStructure: 1,  purpleCircuit: 1}, duration: 200 },

//         science1: { products: { science1: 1 }, costs: { ironGear: 2, ironPlate: 5 }, duration: 50},
//         science2: { products: { science2: 1 }, costs: { engine: 2, greenCircuit: 1 }, duration: 100},
//         science3: { products: { science3: 1 }, costs: { steel: 5, redCircuit: 2 }, duration: 200},
//         science4: { products: { science4: 1 }, costs: { rocketFuel: 5, purpleCircuit: 2,  }, duration: 200},

enum Recipe {
  ironPlate(
      cost: {Material.ironOre: 10},
      products: {Material.ironPlate: 1},
      duration: 10),
  copperPlate(
      cost: {Material.copperOre: 10},
      products: {Material.copperPlate: 1},
      duration: 10),
  ;

  const Recipe(
      {required this.cost, required this.products, required this.duration});

  final Map<Material, double> cost;
  final Map<Material, double> products;
  final double duration;
}
