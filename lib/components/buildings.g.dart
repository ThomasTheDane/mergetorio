// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buildings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingAdapter extends TypeAdapter<Building> {
  @override
  final int typeId = 8;

  @override
  Building read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Building(
      fields[0] as BuildingSpec,
      fields[3] as Vector2,
    )
      ..imageName = fields[1] as String
      ..placedOnTile = fields[2] as Tile
      ..level = fields[4] as int
      ..paused = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.buildingSpec)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.placedOnTile)
      ..writeByte(3)
      ..write(obj.gridPoint)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.paused);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MineAdapter extends TypeAdapter<Mine> {
  @override
  final int typeId = 9;

  @override
  Mine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mine(
      fields[0] as BuildingSpec,
      fields[3] as Vector2,
    )
      ..imageName = fields[1] as String
      ..placedOnTile = fields[2] as Tile
      ..level = fields[4] as int
      ..paused = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, Mine obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.buildingSpec)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.placedOnTile)
      ..writeByte(3)
      ..write(obj.gridPoint)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.paused);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FactoryAdapter extends TypeAdapter<Factory> {
  @override
  final int typeId = 10;

  @override
  Factory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Factory(
      fields[0] as BuildingSpec,
      fields[3] as Vector2,
    )
      ..timeCrafting = fields[6] as double
      ..crafting = fields[7] as bool
      ..stuckOnFull = fields[8] as bool
      ..progressBar = fields[9] as RectangleComponent
      ..progressBarBackground = fields[10] as RectangleComponent
      ..imageName = fields[1] as String
      ..placedOnTile = fields[2] as Tile
      ..level = fields[4] as int
      ..paused = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, Factory obj) {
    writer
      ..writeByte(11)
      ..writeByte(6)
      ..write(obj.timeCrafting)
      ..writeByte(7)
      ..write(obj.crafting)
      ..writeByte(8)
      ..write(obj.stuckOnFull)
      ..writeByte(9)
      ..write(obj.progressBar)
      ..writeByte(10)
      ..write(obj.progressBarBackground)
      ..writeByte(0)
      ..write(obj.buildingSpec)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.placedOnTile)
      ..writeByte(3)
      ..write(obj.gridPoint)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.paused);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommandCenterAdapter extends TypeAdapter<CommandCenter> {
  @override
  final int typeId = 11;

  @override
  CommandCenter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommandCenter(
      fields[0] as dynamic,
      fields[3] as Vector2,
    )
      ..imageName = fields[1] as String
      ..placedOnTile = fields[2] as Tile
      ..level = fields[4] as int
      ..paused = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, CommandCenter obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.buildingSpec)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.placedOnTile)
      ..writeByte(3)
      ..write(obj.gridPoint)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.paused);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandCenterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingTypeAdapter extends TypeAdapter<BuildingType> {
  @override
  final int typeId = 7;

  @override
  BuildingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuildingType.special;
      case 1:
        return BuildingType.mine;
      case 2:
        return BuildingType.factory;
      case 3:
        return BuildingType.lab;
      default:
        return BuildingType.special;
    }
  }

  @override
  void write(BinaryWriter writer, BuildingType obj) {
    switch (obj) {
      case BuildingType.special:
        writer.writeByte(0);
        break;
      case BuildingType.mine:
        writer.writeByte(1);
        break;
      case BuildingType.factory:
        writer.writeByte(2);
        break;
      case BuildingType.lab:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
