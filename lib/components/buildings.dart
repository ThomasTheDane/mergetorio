import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:mergetorio/game.dart';
import 'package:flutter/painting.dart';
import 'tiles.dart';
import 'package:hive/hive.dart';

part 'buildings.g.dart';

@HiveType(typeId: 7)
enum BuildingType {
  @HiveField(0)
  special,
  @HiveField(1)
  mine,
  @HiveField(2)
  factory,
  @HiveField(3)
  lab
}

@HiveType(typeId: 8)
class Building extends SpriteComponent
    with HasGameRef<MergetorioGame>, DragCallbacks, TapCallbacks {
  // @override
  // bool get debugMode => true;
  @HiveField(0)
  late BuildingSpec buildingSpec;
  @HiveField(1)
  late String imageName;

  @HiveField(2)
  late Tile placedOnTile;
  @HiveField(3)
  late Vector2 gridPoint;
  @HiveField(4)
  int level = 1;
  @HiveField(5)
  bool paused = false;

  late TextComponent levelText;

  Building(this.buildingSpec, this.gridPoint) {
    anchor = Anchor.center;
  }

  Building.fromJson(Map<String, dynamic> json) {
    buildingSpec = json['buildingSpec'];
    gridPoint = json['gridPoint]'] ?? Vector2(0, 0);
  }

  Map<String, dynamic> toJson() =>
      {'buildingSpec': buildingSpec, 'gridPoint': gridPoint};

  @override
  Future<void> onLoad() async {
    size =
        Vector2(gameRef.gameGrid.tilePixelSize, gameRef.gameGrid.tilePixelSize);
    placedOnTile =
        gameRef.gameGrid.tiles[gridPoint.y.toInt()][gridPoint.x.toInt()];
    position = Vector2(
        placedOnTile.gridPoint.x * gameRef.gameGrid.tilePixelSize +
            (gameRef.gameGrid.tilePixelSize / 2),
        placedOnTile.gridPoint.y * gameRef.gameGrid.tilePixelSize +
            (gameRef.gameGrid.tilePixelSize / 2));

    gameRef
        .gameGrid
        .tiles[(position.y / gameRef.gameGrid.tilePixelSize).floor()]
            [(position.x / gameRef.gameGrid.tilePixelSize).floor()]
        .buildingPlacedOn = this;

    final TextStyle style = TextStyle(
        color: BasicPalette.darkRed.color,
        fontWeight: FontWeight.bold,
        fontSize: 40);
    final regular = TextPaint(style: style);
    levelText = TextComponent(text: level.toString(), textRenderer: regular);
    add(levelText);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print('tapping building');
    gameRef.detailsModel.updateBuilding(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    print("onDragStart");
    if (!gameRef.isDragging) {
      priority = 100;
      gameRef.isDragging = true;
      gameRef.dragTarget = this;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.delta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    snapToGrid();
    gameRef.isDragging = false;
    print('drag end');
  }

  snapToGrid() {
    var toBePlacedOnTile = gameRef.gameGrid
            .tiles[(position.y / gameRef.gameGrid.tilePixelSize).floor()]
        [(position.x / gameRef.gameGrid.tilePixelSize).floor()];

    if (identical(toBePlacedOnTile, placedOnTile)) {
      position = placedOnTile.center;

      return;
    }

    //check if to be placed on tile already has building
    if (toBePlacedOnTile.buildingPlacedOn == null) {
      //in not then moving is happening so set previous tile building to null
      placedOnTile.buildingPlacedOn = null;
      placedOnTile = toBePlacedOnTile;
      placedOnTile.buildingPlacedOn = this;
    } else {
      //tile has building so check for merge
      if (toBePlacedOnTile.buildingPlacedOn.toString() == toString()) {
        // print("same types");
        //same types
        if (toBePlacedOnTile.buildingPlacedOn?.level == level) {
          //merge!
          placedOnTile.buildingPlacedOn = null;
          placedOnTile = toBePlacedOnTile;

          mergeBuilding(toBePlacedOnTile.buildingPlacedOn);
          placedOnTile.buildingPlacedOn = this;
        }
      }
    }

    // print(placedOnTile.toString());
    position = placedOnTile.center;
  }

  mergeBuilding(Building? absorbedBuilding) {
    print('building merge');
    level += 1;

    levelText.text = level.toString();
    position.x = 100;
    // levelText.x = 200;
    // remove(levelText);
    // remove(absorbedBuilding!.levelText);

    gameRef.remove(absorbedBuilding!);
  }
}

@HiveType(typeId: 9)
class Mine extends Building {
  Mine(BuildingSpec buildingSpec, Vector2 gridPoint)
      : super(buildingSpec, gridPoint) {}

//   Mine.fromJson(Map<String, dynamic> json{
//     super(buildingSpec, gridPoint);
// buildingSpec = json['buildingSpec'];
// gridPoint = json['gridPoint]'];
//   }

//   // @override
//   // Map<String, dynamic> toJson() =>
//   //     {'buildingSpec': buildingSpec, 'gridPoint': gridPoint};

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadSprite();
  }

  _loadSprite() async {
    // imageName = '${recipe.products.toString()}Mine.png';

    imageName =
        "${buildingSpec.recipe.products.toString().split('.').last.split(':').first}Mine.png";
    sprite = await Sprite.load(imageName);
    // sprite = await Sprite.load('ironOreMine.png');
  }

  productionIncrement(dt) {
    if (buildingSpec.recipe.products.keys.contains(placedOnTile.material)) {
      if (!paused) {
        gameRef.inventory.addItem(placedOnTile.material, dt, multiplier: level);
      }
    }
  }

  @override
  mergeBuilding(absorbedBuilding) {
    print('mine merge');
    gameRef.mines.remove(absorbedBuilding);

    super.mergeBuilding(absorbedBuilding);
  }
}

@HiveType(typeId: 10)
class Factory extends Building {
  @HiveField(6)
  double timeCrafting = 0;
  @HiveField(7)
  bool crafting = false;
  @HiveField(8)
  bool stuckOnFull = false;

  @HiveField(9)
  late RectangleComponent progressBar;
  @HiveField(10)
  late RectangleComponent progressBarBackground;

  Factory(BuildingSpec buildingSpec, Vector2 gridPoint)
      : super(buildingSpec, gridPoint) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    progressBarBackground = RectangleComponent.fromRect(
      Rect.fromLTWH(
          0,
          gameRef.gameGrid.tilePixelSize -
              (gameRef.gameGrid.tilePixelSize / 10),
          gameRef.gameGrid.tilePixelSize,
          (gameRef.gameGrid.tilePixelSize / 10)),
    );

    Paint redColor = Paint()..color = Color.fromARGB(255, 255, 0, 0);
    progressBar = RectangleComponent.fromRect(
        Rect.fromLTWH(
            gameRef.gameGrid.tilePixelSize / 100,
            gameRef.gameGrid.tilePixelSize -
                (gameRef.gameGrid.tilePixelSize / 10) +
                (gameRef.gameGrid.tilePixelSize / 100),
            gameRef.gameGrid.tilePixelSize -
                (gameRef.gameGrid.tilePixelSize / 50),
            (gameRef.gameGrid.tilePixelSize / 10) -
                (gameRef.gameGrid.tilePixelSize / 50)),
        paint: redColor);

    add(progressBarBackground);
    add(progressBar);

    await _loadSprite();

    // productionIncrement(100);
  }

  _loadSprite() async {
    imageName = '${buildingSpec.name}.png';

    sprite = await Sprite.load(imageName);
    // sprite = await Sprite.load('ironOreMine.png');
  }

  updateProgressBar(factor) {
    progressBar.width = ((gameRef.gameGrid.tilePixelSize -
            (gameRef.gameGrid.tilePixelSize / 10) +
            (gameRef.gameGrid.tilePixelSize / 100)) *
        (factor));
  }

  productionIncrement(dt) {
    // print(timeCrafting);
    if (crafting) {
      if (!paused) {
        timeCrafting += dt * level;
      }
    } else {
      //see if we can start recipe
      if (gameRef.inventory.checkIfCanSubtract(buildingSpec.recipe.cost)) {
        //start crafting
        gameRef.inventory.subtractItems(buildingSpec.recipe.cost);
        crafting = true;
      }
    }
    if (timeCrafting >= buildingSpec.recipe.duration) {
      //done crafting
      //check if inventory can accept products
      if (gameRef.inventory.checkIfCanAdd(buildingSpec.recipe.products)) {
        gameRef.inventory.addItems(buildingSpec.recipe.products);
        timeCrafting = 0;
        crafting = false;
      }
    }

    updateProgressBar(timeCrafting / buildingSpec.recipe.duration);
  }

  @override
  mergeBuilding(absorbedBuilding) {
    print('fac merge');
    //sum up progress on buildings
    if (absorbedBuilding is Factory) {
      timeCrafting = timeCrafting + absorbedBuilding.timeCrafting;
      if (timeCrafting > buildingSpec.recipe.duration) {
        //add the crafted products
        gameRef.inventory.addItems(buildingSpec.recipe.products);

        //add the extra time
        double extraTime = timeCrafting - buildingSpec.recipe.duration;
        //With the new crafting speed the time spent should be applied at ratio of newSpeed / oldSpeed
        timeCrafting = extraTime * ((level + 1) / (level) / 2);
        print(
            "extra time left over: ${extraTime * ((level + 1) / (level))} / ${buildingSpec.recipe.duration}");
      }
    }

    gameRef.factories.remove(absorbedBuilding);
    super.mergeBuilding(absorbedBuilding);
  }
}

@HiveType(typeId: 11)
class CommandCenter extends Building {
  CommandCenter(buildingSpec, Vector2 gridPoint)
      : super(buildingSpec, gridPoint) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadSprite();

    levelText.text = "";
    // productionIncrement(100);
  }

  _loadSprite() async {
    print("loading command");
    imageName = 'CommandCenter.png';
    sprite = await Sprite.load(imageName);
    priority = 100;

    // sprite = await Sprite.load('ironOreMine.png');
  }
}
