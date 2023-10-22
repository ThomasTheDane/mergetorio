// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiles.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileAdapter extends TypeAdapter<Tile> {
  @override
  final int typeId = 12;

  @override
  Tile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tile(
      fields[0] as Material,
      fields[1] as Vector2,
    )
      ..tilePixelSize = fields[2] as double
      ..buildingPlacedOn = fields[3] as Building?;
  }

  @override
  void write(BinaryWriter writer, Tile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.material)
      ..writeByte(1)
      ..write(obj.gridPoint)
      ..writeByte(2)
      ..write(obj.tilePixelSize)
      ..writeByte(3)
      ..write(obj.buildingPlacedOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
