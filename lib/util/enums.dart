import 'package:flutter/widgets.dart';

enum BuildingType { special, mine, factory, lab }

enum Material {
  dirt,
  ironOre,
  ironPlate,
  ironGear,
  science1,

  engine,
  copperOre,
  copperPlate,
  copperCable,
  greenCircuit,
  science2,

  oil,
  petroleum,
  lightOil,
  heavyOil,

  coal,
  steel
}

enum Recipe {
  empty(cost: {}, products: {}, duration: 1),
  ironOre(cost: {}, products: {Material.ironOre: 1}, duration: 5),
  ironPlate(
      cost: {Material.ironOre: 2},
      products: {Material.ironPlate: 1},
      duration: 10),
  ironGear(
      cost: {Material.ironPlate: 2},
      products: {Material.ironGear: 1},
      duration: 20),
  science1(
      cost: {Material.ironPlate: 10, Material.ironGear: 5},
      products: {Material.science1: 1},
      duration: 30),
  engine(
      cost: {Material.ironPlate: 5, Material.ironGear: 1},
      products: {Material.engine: 1},
      duration: 10),

  copperOre(cost: {}, products: {Material.copperOre: 1}, duration: 10),
  copperPlate(
      cost: {Material.copperOre: 1},
      products: {Material.copperPlate: 1},
      duration: 10),
  copperCable(
      cost: {Material.copperPlate: 1},
      products: {Material.copperCable: 2},
      duration: 5),
  greenCircuit(
      cost: {Material.copperCable: 10, Material.copperPlate: 2},
      products: {Material.greenCircuit: 1},
      duration: 20),
  science2(
      cost: {Material.engine: 10, Material.greenCircuit: 5},
      products: {Material.science2: 1},
      duration: 40),
  steel(
      cost: {Material.ironOre: 10, Material.coal: 1},
      products: {Material.steel: 1},
      duration: 20);

  const Recipe(
      {required this.cost, required this.products, required this.duration});

  final Map<Material, double> cost;
  final Map<Material, double> products;
  final double duration;
}

enum BuildingSpec {
  command(type: BuildingType.special, cost: {}, recipe: Recipe.empty),
  ironOreMine(
      type: BuildingType.mine,
      cost: {Material.ironOre: 10},
      recipe: Recipe.ironOre),
  ironPlateFactory(
      type: BuildingType.factory,
      cost: {Material.ironOre: 20},
      recipe: Recipe.ironPlate),
  ironGearFactory(
      type: BuildingType.factory,
      cost: {Material.ironPlate: 10},
      recipe: Recipe.ironGear),
  science1Lab(
      type: BuildingType.lab,
      cost: {Material.ironGear: 10},
      recipe: Recipe.science1),
  engineFactory(
      type: BuildingType.factory,
      cost: {Material.ironGear: 20},
      recipe: Recipe.engine),
  copperOreMine(
      type: BuildingType.mine,
      cost: {Material.copperOre: 10},
      recipe: Recipe.copperOre),
  copperPlateFactory(
      type: BuildingType.factory,
      cost: {Material.copperOre: 20},
      recipe: Recipe.copperPlate),
  copperCableFactory(
      type: BuildingType.factory,
      cost: {Material.copperPlate: 20},
      recipe: Recipe.copperCable),
  greenCircuitFactory(
      type: BuildingType.factory,
      cost: {Material.copperCable: 20},
      recipe: Recipe.greenCircuit),
  science2Factory(
      type: BuildingType.lab,
      cost: {Material.greenCircuit: 5},
      recipe: Recipe.science2),
  // steelPlateFactory(
  //     type: BuildingType.factory,
  //     cost: {Material.coal: 10},
  //     recipe: Recipe.steel);
  ;

  const BuildingSpec(
      {required this.type, required this.cost, required this.recipe});

  final BuildingType type;
  final Map<Material, double> cost;
  final Recipe recipe;
}

enum TechUpgrade {
  expand1(cost: {Material.science1: 1}, prerequisites: []),

  ironOreMine(cost: {Material.science1: 10}, prerequisites: []),
  ironPlateFactory(cost: {Material.science1: 10}, prerequisites: []),
  ironGearFactory(cost: {Material.science1: 20}, prerequisites: []),
  science1Lab(cost: {Material.science1: 40}, prerequisites: []),
  engineFactory(cost: {Material.science1: 20}, prerequisites: []),
  copperOreMine(
      cost: {Material.science1: 50}, prerequisites: [TechUpgrade.expand1]),
  copperPlateFactory(
      cost: {Material.science1: 60},
      prerequisites: [TechUpgrade.copperOreMine]),
  copperCableFactory(
      cost: {Material.science1: 70},
      prerequisites: [TechUpgrade.copperPlateFactory]),
  greenCircuitFactory(
      cost: {Material.science1: 80},
      prerequisites: [TechUpgrade.copperCableFactory]),
  science2Factory(cost: {
    Material.science1: 100
  }, prerequisites: [
    TechUpgrade.greenCircuitFactory,
    TechUpgrade.engineFactory
  ])
  // steelPlateFactory(cost: {Material.science1: 100}, prerequisites: [])
  ;

  const TechUpgrade({required this.cost, required this.prerequisites});

  final Map<Material, double> cost;
  final List<TechUpgrade> prerequisites;
}


// copperPlate: { products: { copperPlate: 1 }, costs: { copperOre: 2 }, duration: 2 },
// copperCable: { products: { copperCable: 1 }, costs: { copperPlate: 2 }, duration: 4 },

// engine: { products: { engine: 1 }, costs: { ironPlate: 4, ironGear: 2}, duration: 8 },
// greenCircuit: { products: { greenCircuit: 1 }, costs: { copperPlate: 2, copperCable: 1 }, duration: 5 },

// oilProcessing1: { products: { petroleum: 1 }, costs: { oil: 5 }, duration: 5 },

// steel: { products: { steel: 1 }, costs: { ironPlate:  2, coal: 4}, duration: 5 },
// plastic: { products: { plastic: 1 }, costs: { petroleum:  2, coal: 2}, duration: 5 },
// redCircuit: { products: { redCircuit: 1 }, costs: { greenCircuit:  5, plastic: 2}, duration: 5 },
