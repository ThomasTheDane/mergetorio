import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:mergetorio/game.dart';
import 'package:flutter/painting.dart';
import 'tiles.dart';
import '../util/util.dart';
import '../util/enums.dart';

class Building extends SpriteComponent
    with HasGameRef<MergetorioGame>, DragCallbacks, TapCallbacks {
  // @override
  // bool get debugMode => true;
  late BuildingSpec buildingSpec;
  late String imageName;

  late Tile placedOnTile;
  late Vector2 gridPoint;
  int level = 1;
  bool paused = false;

  late TextComponent levelText;

  Building(this.buildingSpec, this.gridPoint) {
    anchor = Anchor.center;
  }

  Building.fromJson(Map<String, dynamic> json) {
    anchor = Anchor.center;

    buildingSpec = BuildingSpec.values.byName(json["buildingSpec"]);
    gridPoint = vec2FromJson(json["gridPoint"]);
    level = int.parse(json["level"]);
    paused = bool.parse(json["paused"]);
  }

  Map<String, dynamic> toJson() => {
        '"buildingSpec"': '"${buildingSpec.toString().split(".").last}"',
        '"gridPoint"': '"${gridPoint.toString()}"',
        '"level"': '"$level"',
        '"paused"': '"$paused"'
      };

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

  moveBuildingToGridpoint(gridPoint) {
    var toBePlacedOnTile = gameRef.gameGrid.tiles[gridPoint.y][gridPoint.x];

    placedOnTile.buildingPlacedOn = null;
    placedOnTile = toBePlacedOnTile;
    placedOnTile.buildingPlacedOn = this;
    position = placedOnTile.center;
    // position = Vector2(
    //     (gridPoint.x * gameRef.gameGrid.tilePixelSize) +
    //         (gameRef.gameGrid.tilePixelSize / 2),
    //     (gridPoint.y * gameRef.gameGrid.tilePixelSize) +
    //         (gameRef.gameGrid.tilePixelSize / 2));
  }

  destroy() {
    placedOnTile.buildingPlacedOn = null;
    gameRef.world.remove(this);
  }

  resizeAndLayout() {
    size =
        Vector2(gameRef.gameGrid.tilePixelSize, gameRef.gameGrid.tilePixelSize);
    position = placedOnTile.center;
  }

  snapToGrid() {
    var toBePlacedOnTile = gameRef.gameGrid
            .tiles[(position.y / gameRef.gameGrid.tilePixelSize).floor()]
        [(position.x / gameRef.gameGrid.tilePixelSize).floor()];

    //if same tile it came from, abort and snap back
    if (identical(toBePlacedOnTile, placedOnTile)) {
      position = placedOnTile.center;

      return;
    }

    //check if to be placed on tile already has building
    if (toBePlacedOnTile.buildingPlacedOn == null) {
      //if not then moving is happening so set previous tile building to null
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

          //todo I think I need to refund one recipe worth since while the timeCrafting should add up, since I don't give 2x the output you end up loosing resources when you merge

          mergeBuilding(toBePlacedOnTile.buildingPlacedOn);
          placedOnTile.buildingPlacedOn = this;
        }
      }
    }

    // print(placedOnTile.toString());
    position = placedOnTile.center;
    gridPoint = Vector2(
        (position.x / gameRef.gameGrid.tilePixelSize).floor() as double,
        (position.y / gameRef.gameGrid.tilePixelSize).floor() as double);
  }

  mergeBuilding(Building? absorbedBuilding) {
    print('building merge');
    level += 1;

    levelText.text = level.toString();
    position.x = 100;

    gameRef.world.remove(absorbedBuilding!);
  }
}

class Mine extends Building {
  Mine(BuildingSpec buildingSpec, Vector2 gridPoint)
      : super(buildingSpec, gridPoint) {}

  Mine.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    // print("making mine from json with spec $buildingSpec at $gridPoint");
  }

  Map<String, dynamic> toJson() => super.toJson();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadSprite();
  }

  _loadSprite() async {
    // imageName = '${recipe.products.toString()}Mine.png';

    imageName =
        "${buildingSpec.toString().split('.').last.split(':').first}.png";
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

class Factory extends Building {
  double timeCrafting = 0;
  bool crafting = false;
  bool stuckOnFull = false;

  late RectangleComponent progressBar;
  late RectangleComponent progressBarBackground;

  Factory(BuildingSpec buildingSpec, Vector2 gridPoint)
      : super(buildingSpec, gridPoint) {}

  Factory.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    print("making factory from json with spec $buildingSpec at $gridPoint");
    timeCrafting = double.parse(json["timeCrafting"]);
    crafting = bool.parse(json["crafting"]);
    stuckOnFull = bool.parse(json["stuckOnFull"]);
  }

  Map<String, dynamic> toJson() => {}
    ..addAll(super.toJson())
    ..addAll({
      '"timeCrafting"': '"$timeCrafting"',
      '"crafting"': '"$crafting"',
      '"stuckOnFull"': '"$stuckOnFull"',
    });

  @override
  Future<void> onLoad() async {
    print("factory onload function");
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

  @override
  resizeAndLayout() {
    super.resizeAndLayout();

    progressBarBackground.position = Vector2(
      0,
      gameRef.gameGrid.tilePixelSize - (gameRef.gameGrid.tilePixelSize / 10),
    );
    progressBarBackground.size = Vector2(
        gameRef.gameGrid.tilePixelSize, gameRef.gameGrid.tilePixelSize / 10);

    progressBar.position = Vector2(
        gameRef.gameGrid.tilePixelSize / 100,
        gameRef.gameGrid.tilePixelSize -
            (gameRef.gameGrid.tilePixelSize / 10) +
            (gameRef.gameGrid.tilePixelSize / 100));
    progressBar.size = Vector2(
        gameRef.gameGrid.tilePixelSize - (gameRef.gameGrid.tilePixelSize / 50),
        (gameRef.gameGrid.tilePixelSize / 10) -
            (gameRef.gameGrid.tilePixelSize / 50));
  }

  updateProgressBar(factor) {
    progressBar.width = ((gameRef.gameGrid.tilePixelSize -
            (gameRef.gameGrid.tilePixelSize / 10) +
            (gameRef.gameGrid.tilePixelSize / 100)) *
        (factor));
  }

  productionIncrement(dt) {
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
        //if can add, then add items
        gameRef.inventory.addItems(buildingSpec.recipe.products);

        //set time crafting to the production increment if we can start craft
        if (gameRef.inventory.checkIfCanSubtract(buildingSpec.recipe.cost)) {
          //start crafting
          gameRef.inventory.subtractItems(buildingSpec.recipe.cost);
          crafting = true;
          timeCrafting = timeCrafting - buildingSpec.recipe.duration;
          //if time crafting > recipe our granularity is too low
          if (timeCrafting >= buildingSpec.recipe.duration) {
            throw FormatException(
                "Crafting time > recipe after craft, internal too coarse ");
          }
        } else {
          timeCrafting = 0;
        }

        crafting = false;
      }
    }

    updateProgressBar(timeCrafting / buildingSpec.recipe.duration);
  }

  @override
  mergeBuilding(absorbedBuilding) {
    print('fac merge');
    //todo - if some of the buildings are crafting yet then they shouldn't add their value to the production or infer the costs of production onward
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

class CommandCenter extends Building {
  CommandCenter(buildingSpec, Vector2 gridPoint)
      : super(buildingSpec, gridPoint) {}

  Map<String, dynamic> toJson() => super.toJson();

  CommandCenter.fromJson(Map<String, dynamic> json) : super.fromJson(json) {}

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
