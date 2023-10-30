import 'dart:math';

// import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import 'tiles.dart';
import '../game.dart';
import '../util/enums.dart';

class GameGrid extends Component with HasGameRef<MergetorioGame> {
  int gridWidth = 3;
  int gridHeight = 3;
  double gridPixelSize = 1000;
  double tilePixelSize = 200;

  List<List<String>> tileMap1 = [
    ["d", "d", "d", "d"],
    ["d", "d", "i", "d"],
    ["d", "i", "d", "i"],
    ["d", "d", "d", "c"]
  ]; //todo implement pulling from this and storing it in save

  List<List<Tile>> tiles = [[]];

  GameGrid() {
    generateDefaultMapTiles();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> returnJson = {};
    returnJson['"gridWidth"'] = '"$gridWidth"';
    returnJson['"gridHeight"'] = '"$gridHeight"';
    returnJson['"gridPixelSize"'] = '"$gridPixelSize"';
    returnJson['"tilePixelSize"'] = '"$tilePixelSize"';

    // returnJson['"tiles"'] = List.generate(
    //     gridHeight,
    //     (y) => List.generate(gridWidth, (x) {
    //           return tiles[y][x].toJson();
    //         }));

    return returnJson;
  }

  GameGrid.fromJson(Map<String, dynamic> json) {
    gridWidth = int.parse(json["gridWidth"]);
    gridHeight = int.parse(json["gridHeight"]);
    gridPixelSize = double.parse(json["gridPixelSize"]);
    tilePixelSize = double.parse(json["tilePixelSize"]);
    generateDefaultMapTiles();
  }

  @override
  Future<void> onLoad() async {
    gridPixelSize = gameRef.size.x;
    tilePixelSize = min(gridPixelSize / gridWidth, gridPixelSize / gridHeight);
    addTilesToGame();
  }

  Tile getTileFromMap(List<List<String>> map, int x, int y) {
    if (y > map.length - 1 || x > map[y].length - 1) {
      print("ran out of map, returning DIRT ");
      return Tile(Material.dirt, Vector2(x.toDouble(), y.toDouble()));
    }
    if (map[y][x] == "d") {
      return Tile(Material.dirt, Vector2(x.toDouble(), y.toDouble()));
    }
    if (map[y][x] == "i") {
      return Tile(Material.ironOre, Vector2(x.toDouble(), y.toDouble()));
    }
    if (map[y][x] == "c") {
      return Tile(Material.copperOre, Vector2(x.toDouble(), y.toDouble()));
    }

    print("Tile icon not found, returning DIRT");
    return Tile(Material.dirt, Vector2(x.toDouble(), y.toDouble()));
  }

  generateTilesEmptyGrid() {
    tiles = List.generate(
        gridHeight,
        (y) => List.generate(gridWidth, (x) {
              Tile aTile =
                  Tile(Material.dirt, Vector2(x.toDouble(), y.toDouble()));
              // gameRef.add(aTile);
              return aTile;
            }, growable: true),
        growable: true);
  }

  generateDefaultMapTiles() {
    tiles = List.generate(
        gridHeight,
        (y) => List.generate(gridWidth, (x) {
              Tile aTile = getTileFromMap(tileMap1, x, y);

              // gameRef.add(aTile);

              return aTile;
            }, growable: true),
        growable: true);
  }

  addTilesToGame() {
    for (List<Tile> tileRow in tiles) {
      for (Tile aTile in tileRow) {
        gameRef.add(aTile);
      }
    }
  }

  growGridRight() {
    gridWidth += 1;
    tilePixelSize = min(gridPixelSize / gridWidth, gridPixelSize / gridHeight);
    double y = 0;
    for (List<Tile> tileRow in tiles) {
      Tile newTile = getTileFromMap(tileMap1, gridWidth - 1, y as int);
      tileRow.add(newTile);
      gameRef.add(newTile);
      y += 1;
    }
  }

  growGridDown() {
    gridHeight += 1;
    tilePixelSize = min(gridPixelSize / gridWidth, gridPixelSize / gridHeight);
    List<Tile> newTileRow = List.generate(gridWidth, (x) {
      Tile aTile = getTileFromMap(tileMap1, x, gridHeight - 1);
      gameRef.add(aTile);
      return aTile;
    }, growable: true);
    tiles.add(newTileRow);
    // for (List<Tile> tileRow in tiles) {
    //   Tile newTile = Tile(Material.dirt, Vector2(gridWidth - 1 as double, y));
    //   tileRow.add(newTile);
    //   gameRef.add(newTile);
    //   y += 1;
    // }
  }

  resizeAndLayout() {
    tilePixelSize = min(gridPixelSize / gridWidth, gridPixelSize / gridHeight);

    for (List<Tile> tileRow in tiles) {
      for (Tile aTile in tileRow) {
        aTile.updateSizeAndPosition();
        if (aTile.buildingPlacedOn != null) {
          aTile.buildingPlacedOn!.resizeAndLayout();
        }
      }
    }
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

  destroy() {
    for (List<Tile> tileRow in tiles) {
      for (Tile aTile in tileRow) {
        gameRef.remove(aTile);
      }
    }
  }
}
