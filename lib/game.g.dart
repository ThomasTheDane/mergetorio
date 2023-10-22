// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MergetorioGameAdapter extends TypeAdapter<MergetorioGame> {
  @override
  final int typeId = 0;

  @override
  MergetorioGame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MergetorioGame(
      fields[0] as Inventory,
      fields[2] as DetailsModel,
      fields[1] as Store,
    )..gameGrid = fields[3] as GameGrid;
  }

  @override
  void write(BinaryWriter writer, MergetorioGame obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.inventory)
      ..writeByte(1)
      ..write(obj.store)
      ..writeByte(2)
      ..write(obj.detailsModel)
      ..writeByte(3)
      ..write(obj.gameGrid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MergetorioGameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameGridAdapter extends TypeAdapter<GameGrid> {
  @override
  final int typeId = 6;

  @override
  GameGrid read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameGrid()
      ..tiles = (fields[0] as List)
          .map((dynamic e) => (e as List).cast<Tile>())
          .toList()
      ..gridWidth = fields[1] as int
      ..gridHeight = fields[2] as int
      ..gridPixelSize = fields[3] as double
      ..tilePixelSize = fields[4] as double;
  }

  @override
  void write(BinaryWriter writer, GameGrid obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tiles)
      ..writeByte(1)
      ..write(obj.gridWidth)
      ..writeByte(2)
      ..write(obj.gridHeight)
      ..writeByte(3)
      ..write(obj.gridPixelSize)
      ..writeByte(4)
      ..write(obj.tilePixelSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameGridAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryAdapter extends TypeAdapter<Inventory> {
  @override
  final int typeId = 1;

  @override
  Inventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inventory()
      ..gameRef = fields[0] as MergetorioGame
      ..materials = (fields[1] as Map).cast<Material, double>()
      ..rates = (fields[2] as Map).cast<Material, double>();
  }

  @override
  void write(BinaryWriter writer, Inventory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.gameRef)
      ..writeByte(1)
      ..write(obj.materials)
      ..writeByte(2)
      ..write(obj.rates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoreAdapter extends TypeAdapter<Store> {
  @override
  final int typeId = 3;

  @override
  Store read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Store()
      ..availableBuildings = (fields[0] as List).cast<BuildingSpec>()
      ..gameRef = fields[1] as MergetorioGame
      ..purchaseLevel = (fields[2] as Map).cast<BuildingSpec, int>();
  }

  @override
  void write(BinaryWriter writer, Store obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.availableBuildings)
      ..writeByte(1)
      ..write(obj.gameRef)
      ..writeByte(2)
      ..write(obj.purchaseLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DetailsModelAdapter extends TypeAdapter<DetailsModel> {
  @override
  final int typeId = 5;

  @override
  DetailsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetailsModel()..selectedBuilding = fields[0] as Building?;
  }

  @override
  void write(BinaryWriter writer, DetailsModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.selectedBuilding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialAdapter extends TypeAdapter<Material> {
  @override
  final int typeId = 2;

  @override
  Material read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Material.dirt;
      case 1:
        return Material.ironOre;
      case 2:
        return Material.ironPlate;
      case 3:
        return Material.ironGear;
      case 4:
        return Material.science1;
      case 5:
        return Material.engine;
      case 6:
        return Material.copperOre;
      case 7:
        return Material.copperPlate;
      case 8:
        return Material.copperCable;
      case 9:
        return Material.greenCircuit;
      case 10:
        return Material.science2;
      case 11:
        return Material.oil;
      case 12:
        return Material.petroleum;
      case 13:
        return Material.lightOil;
      case 14:
        return Material.heavyOil;
      case 15:
        return Material.coal;
      case 16:
        return Material.steel;
      default:
        return Material.dirt;
    }
  }

  @override
  void write(BinaryWriter writer, Material obj) {
    switch (obj) {
      case Material.dirt:
        writer.writeByte(0);
        break;
      case Material.ironOre:
        writer.writeByte(1);
        break;
      case Material.ironPlate:
        writer.writeByte(2);
        break;
      case Material.ironGear:
        writer.writeByte(3);
        break;
      case Material.science1:
        writer.writeByte(4);
        break;
      case Material.engine:
        writer.writeByte(5);
        break;
      case Material.copperOre:
        writer.writeByte(6);
        break;
      case Material.copperPlate:
        writer.writeByte(7);
        break;
      case Material.copperCable:
        writer.writeByte(8);
        break;
      case Material.greenCircuit:
        writer.writeByte(9);
        break;
      case Material.science2:
        writer.writeByte(10);
        break;
      case Material.oil:
        writer.writeByte(11);
        break;
      case Material.petroleum:
        writer.writeByte(12);
        break;
      case Material.lightOil:
        writer.writeByte(13);
        break;
      case Material.heavyOil:
        writer.writeByte(14);
        break;
      case Material.coal:
        writer.writeByte(15);
        break;
      case Material.steel:
        writer.writeByte(16);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingSpecAdapter extends TypeAdapter<BuildingSpec> {
  @override
  final int typeId = 4;

  @override
  BuildingSpec read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuildingSpec.command;
      case 1:
        return BuildingSpec.ironOreMine;
      case 2:
        return BuildingSpec.ironPlateFactory;
      case 3:
        return BuildingSpec.ironGearFactory;
      case 4:
        return BuildingSpec.science1Lab;
      case 5:
        return BuildingSpec.copperPlateFactory;
      case 6:
        return BuildingSpec.steelPlateFactory;
      default:
        return BuildingSpec.command;
    }
  }

  @override
  void write(BinaryWriter writer, BuildingSpec obj) {
    switch (obj) {
      case BuildingSpec.command:
        writer.writeByte(0);
        break;
      case BuildingSpec.ironOreMine:
        writer.writeByte(1);
        break;
      case BuildingSpec.ironPlateFactory:
        writer.writeByte(2);
        break;
      case BuildingSpec.ironGearFactory:
        writer.writeByte(3);
        break;
      case BuildingSpec.science1Lab:
        writer.writeByte(4);
        break;
      case BuildingSpec.copperPlateFactory:
        writer.writeByte(5);
        break;
      case BuildingSpec.steelPlateFactory:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingSpecAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
