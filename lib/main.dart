import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'components/buildings.dart';
import 'game.dart' as Game;
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'util/util.dart' as utils;

var inventoryModel = Game.Inventory();
var detailsModel = DetailsModel();
var storeModel = Game.Store();
final game = Game.MergetorioGame(inventoryModel, detailsModel, storeModel);

void main() {
  storeModel.gameRef = game;

  runApp(
      // ChangeNotifierProvider(
      // create: (context) => inventoryModel,

      MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => inventoryModel),
    ChangeNotifierProvider(create: (context) => detailsModel),
    ChangeNotifierProvider(create: (context) => storeModel)
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mergetorio',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: utils.lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: utils.darkColorScheme,
        textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(children: [
        Container(
            height: constraints.maxHeight * 0.20,
            width: constraints.maxWidth,
            color: Colors.grey,
            child: InventoryView()),
        Container(
          height: constraints.maxHeight * 0.55,
          width: constraints.maxWidth,
          color: Colors.purpleAccent,
          child: GameWidget(game: game),
        ),
        Container(
          height: constraints.maxHeight * 0.25,
          width: constraints.maxWidth,
          color: Colors.lightBlue,
          child: DetailView(),
        ),
        // Text('I love you babe '),
      ]);
    });
  }
}

class InventoryView extends StatelessWidget {
  InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // List<ResourceItemView> materialToRender;

    return Consumer<Game.Inventory>(
      builder: (context, inventory, child) {
        // print(inventory.materials[Game.Material.ironOre]);
        return ListView(
          // This next line does the trick.
          scrollDirection: Axis.horizontal,
          children: [
            for (var aMaterial in inventory.materials.keys)
              ResourceItemView(aMaterial)
            // ResourceItemView(Game.Material.copperOre),
            // ResourceItemView(Game.Material.ironOre),
            // ResourceItemView(Game.Material.ironOre),
            // ResourceItemView(Game.Material.ironOre),
            // ResourceItemView(Game.Material.ironOre),
          ],
        );
      },
    );
  }
}

class ResourceItemView extends StatefulWidget {
  Game.Material material;

  ResourceItemView(this.material, {super.key});

  @override
  State<ResourceItemView> createState() => _ResourceItemViewState(material);
}

class _ResourceItemViewState extends State<ResourceItemView> {
  Game.Material material;

  _ResourceItemViewState(this.material);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
          width: min(MediaQuery.of(context).size.width * (1.5 / 8),
              MediaQuery.of(context).size.height / 10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Text(
                "${utils.prettyNames(material)}",
                // "pie",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none),
              ),
            ),
            Container(
                child: Image.asset(
                    '../assets/images/${widget.material.toString().split('.').last}.png')),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  child:
                      // Consumer<Game.Inventory>(
                      //   builder: (context, inventoryModel, child) {
                      //     print('in builder');
                      // return
                      Text(
                    utils.prettyFormat(inventoryModel.materials[material]),
                    // "${inventoryModel.materials[widget.material]?.floor() ?? 0}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  )
                  // },
                  ),
              // ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Text(
                    '<3',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  )),
            ])
            // Text('resourceRate'),
          ])),
    );
  }
}

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsModel>(builder: (context, detailsModel, child) {
      if (detailsModel.selectedBuilding is CommandCenter) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Construction Center",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none)),
            ),
            SizedBox(width: 500, height: 180, child: StoreView())
          ],
        );
      }
      if (detailsModel.selectedBuilding is Mine) {
        return MineView();
      }

      if (detailsModel.selectedBuilding is Factory) {
        return FactoryView();
      }
      return Placeholder();
    });
  }
}

class StoreView extends StatelessWidget {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(scrollDirection: Axis.horizontal, children: [
      for (Game.BuildingSpec aSpec in storeModel.availableBuildings)
        StoreItem(aSpec),
      // StoreItem(Game.BuildingSpec.copperPlateFactory),
      // StoreItem(Game.BuildingSpec.ironPlateFactory),
      // StoreItem(Game.BuildingSpec.ironOreMine),
      // StoreItem(Game.BuildingSpec.ironOreMine),
      // StoreItem(Game.BuildingSpec.ironOreMine),
      // StoreItem(Game.BuildingSpec.ironOreMine)
    ]);
  }
}

//   return Consumer<Game.Store>(builder: (context, storeModel, child) {
//     return ListView(
//       shrinkWrap: true,
//       // scrollDirection: Axis.horizontal,
//       // children: [StoreItem(Game.BuildingSpec.ironOreMine)],
//       // children: [ResourceItemView(Game.Material.ironOre)],
//     );

//     return ListView(
//         // This next line does the trick.
//         scrollDirection: Axis.horizontal,
//         children: [StoreItem(Game.BuildingSpec.ironOreMine)]);
//   });
// }

class StoreItem extends StatefulWidget {
  Game.BuildingSpec _buildingSpec;

  StoreItem(this._buildingSpec, {super.key});

  @override
  State<StoreItem> createState() => _StoreItemState(_buildingSpec);
}

class _StoreItemState extends State<StoreItem> {
  Game.BuildingSpec _buildingSpec;

  _StoreItemState(this._buildingSpec);

  @override
  Widget build(BuildContext context) {
    // ${material.toString().split('.').last
    print(widget._buildingSpec.toString().split('.').last);
    return GestureDetector(
        onTap: () {
          storeModel.handleBuy(_buildingSpec);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(),
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                            "../assets/images/${widget._buildingSpec.toString().split('.').last}.png"))),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var aCost in widget._buildingSpec.cost.keys)
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: SizedBox(height: 30, width: 30, child: Image.asset(
                                  //value: _buildingSpec.cost[aCost].toString().split('.').last
                                  "../assets/images/${aCost.toString().split('.').last}.png"))),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                                widget._buildingSpec.cost[aCost]
                                    .toString()
                                    .split('.')
                                    .last,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none)),
                          )
                        ],
                      )
                  ],
                )
                // Placeholder()
              ],
            ),
          ),
        ));
  }
}

class MineView extends StatelessWidget {
  const MineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsModel>(builder: (context, detailsModel, child) {
      String imageURL =
          '../assets/images/${detailsModel.selectedBuilding?.imageName}';

      return LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Text(
                  utils.prettyBuildingNames(detailsModel.selectedBuilding),
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: SizedBox(
                            height: 120,
                            width: 120,
                            child: Image.asset(imageURL)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: Text(
                            "Rate: ${detailsModel.selectedBuilding?.level}",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: Text("Total Mined: 223k",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none)),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 30, right: 50),
                        child: ElevatedButton(
                            onPressed: detailsModel.pauseClick,
                            child: const Text('Pause')),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 30, right: 50),
                        child: ElevatedButton(
                            onPressed: detailsModel.refundClick,
                            child: const Text('Refund')),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        );
      });
    });
  }
}

class FactoryView extends StatelessWidget {
  const FactoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsModel>(builder: (context, detailsModel, child) {
      String imageURL =
          '../assets/images/${detailsModel.selectedBuilding?.imageName}';

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 5),
          child: Text(utils.prettyBuildingNames(detailsModel.selectedBuilding),
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none)),
        ),
        Expanded(
            child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 100, width: 100, child: Image.asset(imageURL)),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: Text("Rate: ${detailsModel.selectedBuilding?.level}",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: Text("Total made: 223k",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none)),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var aFacCost in detailsModel
                              .selectedBuilding!.recipe.cost.keys)
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),

                                // height: 50,
                                // width: 50,
                                child: Image.asset(
                                    "../assets/images/${aFacCost.toString().split('.').last}.png"))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("../assets/images/arrow.png"),
                          Text(
                              "${detailsModel.selectedBuilding!.recipe.duration.toString()} s",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var aFacProduct in detailsModel
                              .selectedBuilding!.recipe.products.keys)
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),

                                // height: 50,
                                // width: 50,
                                child: Image.asset(
                                    "../assets/images/${aFacProduct.toString().split('.').last}.png"))
                        ],
                      ),
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0, top: 0, right: 0, bottom: 10),
                      child: IconButton(
                        icon: const Icon(Icons.pause),
                        tooltip: 'Pause',
                        onPressed: detailsModel.pauseClick,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 0, top: 10, right: 0),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Refund',
                        onPressed: detailsModel.refundClick,
                      ),
                    )
                  ],
                )),
          ],
        ))
      ]);
    });
  }
}

class DetailsModel extends ChangeNotifier {
  Building? selectedBuilding;

  DetailsModel() {
    // selectedBuilding = game.factories[0];
    // selectedBuilding = Mine(Game.Recipe.ironOre, Vector2(1, 1));
  }

  updateBuilding(newBuilding) {
    selectedBuilding = newBuilding;
    print("showing new building in details view");
    print(newBuilding);
    notifyListeners();
  }

  pauseClick() {
    print('pausing building');
  }

  refundClick() {
    print('refund!');
  }
}
