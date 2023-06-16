import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mergetorio/game.dart';
import 'buildings.dart';

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

  _loadSprite() async {
    // todo: replace with ${} syntax
    sprite = await Sprite.load('${material.toString().split('.').last}.png');
    // switch (material) {
    //   case Material.dirt:
    //     sprite = await Sprite.load('dirt.png');
    //     break;
    //   case Material.ironOre:
    //     sprite = await Sprite.load('ironOre.png');
    //     break;
    //   default:
    //     sprite = await Sprite.load('dirt.png');
    // }
  }

  @override
  String toString() {
    return "Tile at (${gridPoint.x} , ${gridPoint.y}) with type ${material.toString().split('.').last}";
    // return "pie";
  }

  // @override
  // bool get debugMode => true;
}
