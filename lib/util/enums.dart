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
  ironOre(cost: {}, products: {Material.ironOre: 1}, duration: 1),
  copperOre(cost: {}, products: {Material.ironOre: 1}, duration: 1),
  ironPlate(
      cost: {Material.ironOre: 10},
      products: {Material.ironPlate: 5},
      duration: 10),
  ironGear(
      cost: {Material.ironPlate: 20},
      products: {Material.ironGear: 5},
      duration: 20),
  science1(
      cost: {Material.ironPlate: 10, Material.ironGear: 5},
      products: {Material.science1: 1},
      duration: 30),
  copperPlate(
      cost: {Material.copperOre: 10},
      products: {Material.copperPlate: 1},
      duration: 10),
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
  copperOreMine(
      type: BuildingType.mine,
      cost: {Material.copperOre: 10},
      recipe: Recipe.copperOre),
  copperPlateFactory(
      type: BuildingType.factory,
      cost: {Material.copperOre: 20},
      recipe: Recipe.copperPlate),
  steelPlateFactory(
      type: BuildingType.factory,
      cost: {Material.coal: 10},
      recipe: Recipe.steel);

  const BuildingSpec(
      {required this.type, required this.cost, required this.recipe});

  final BuildingType type;
  final Map<Material, double> cost;
  final Recipe recipe;
}

enum TechUpgrade {
  expand1(cost: {Material.science1: 10}, prerequisites: []),

  ironOreMine(cost: {Material.science1: 10}, prerequisites: []),
  ironPlateFactory(cost: {Material.science1: 10}, prerequisites: []),
  ironGearFactory(cost: {Material.science1: 20}, prerequisites: []),
  science1Lab(cost: {Material.science1: 40}, prerequisites: []),
  copperOreMine(
      cost: {Material.science1: 50}, prerequisites: [TechUpgrade.expand1]),
  copperPlateFactory(
      cost: {Material.science1: 60},
      prerequisites: [TechUpgrade.copperOreMine]),
  // steelPlateFactory(cost: {Material.science1: 100}, prerequisites: [])
  ;

  const TechUpgrade({required this.cost, required this.prerequisites});

  final Map<Material, double> cost;
  final List<TechUpgrade> prerequisites;
}
