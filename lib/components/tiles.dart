import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mergetorio/game.dart';
import 'buildings.dart';
import '../util/enums.dart';

class Tile extends SpriteComponent
    with HasGameRef<MergetorioGame>, TapCallbacks {
  Material material;
  Vector2 gridPoint;
  double tilePixelSize = 100;
  Building? buildingPlacedOn;

  Tile(this.material, this.gridPoint) {
    // var icon = _loadSprite();
    // sprite = icon;
    // print(gameRef);
    // print(gameRef);
    // print(aGameRef);
  }
  Map<String, dynamic> toJson() => {
        '"material"': '"$material"',
        '"gridPoint"': '"$gridPoint"',
        // "tilePixelSize": tilePixelSize,
        // "buildingPlacedOn": buildingPlacedOn
      };

  @override
  void onTapUp(TapUpEvent event) {
    print("tap that, get on the floor");
    print("tap that $material get on ");
    // gameRef.inventory.addItems(additions)
    if (material != Material.dirt) {
      gameRef.inventory.addItem(material, 1);
    }
    // gameRef.inventory.[material] = (gameRef.inventory[material] ?? 0) + 1;
    // print(gameRef.inventory[material]);
  }

  @override
  Future<void> onLoad() async {
    // print("on load");
    await super.onLoad();

    size =
        Vector2(gameRef.gameGrid.tilePixelSize, gameRef.gameGrid.tilePixelSize);
    position = Vector2(gridPoint.x * gameRef.gameGrid.tilePixelSize,
        gridPoint.y * gameRef.gameGrid.tilePixelSize);

    await _loadSprite();
  }

  updateSizeAndPosition() {
    size =
        Vector2(gameRef.gameGrid.tilePixelSize, gameRef.gameGrid.tilePixelSize);
    position = Vector2(gridPoint.x * gameRef.gameGrid.tilePixelSize,
        gridPoint.y * gameRef.gameGrid.tilePixelSize);
  }

  _loadSprite() async {
    sprite =
        await Sprite.load('${material.toString().split('.').last}Tile.png');
  }

  @override
  String toString() {
    return "Tile at (${gridPoint.x} , ${gridPoint.y}) with type ${material.toString().split('.').last}";
    // return "pie";
  }

  // @override
  // bool get debugMode => true;
}
