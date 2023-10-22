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
var detailsModel = Game.DetailsModel();
var storeModel = Game.Store();
// var researchModel = Game.Research();
final game = Game.MergetorioGame(inventoryModel, detailsModel, storeModel);

void main() {
  inventoryModel.gameRef = game;
  storeModel.gameRef = game;
  // researchModel.gameRef = game;

  runApp(MultiProvider(providers: [
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
          textTheme: const TextTheme(
              displaySmall: TextStyle(fontSize: 15),
              // : TextStyle(fontSize: 13),
              bodySmall: TextStyle(fontSize: 13),
              bodyMedium: TextStyle(fontSize: 20),
              bodyLarge: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
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
          ],
        );
      },
    );
  }
}

class ResourceItemView extends StatefulWidget {
  final Game.Material material;

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
              child: Text(utils.prettyNames(material),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
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
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                  // },
                  ),
              // ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Text(
                    "${utils.prettyFormat(inventoryModel.rates[material])}/s",
                    style: Theme.of(context).textTheme.bodySmall,
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
    return Consumer<Game.DetailsModel>(builder: (context, detailsModel, child) {
      if (detailsModel.selectedBuilding is CommandCenter) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Construction Center",
                      style: Theme.of(context).textTheme.displayMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report),
                  tooltip: 'Debug Test',
                  onPressed: game.debugClick,
                ),
                IconButton(
                  icon: const Icon(Icons.bungalow_outlined),
                  tooltip: 'Debug Test',
                  onPressed: game.debugClick2,
                )
              ],
            ),
            SizedBox(width: 500, height: 180, child: StoreView())
          ],
        );
      }
      if (detailsModel.selectedBuilding is Mine) {
        return MineView();
      }

      if (detailsModel.selectedBuilding is Factory) {
        if (detailsModel.selectedBuilding?.buildingSpec.type ==
            BuildingType.factory) {
          return FactoryView();
        }
        if (detailsModel.selectedBuilding?.buildingSpec.type ==
            BuildingType.lab) {
          return LabView();
        }
      }
      return Placeholder();
    });
  }
}

class StoreView extends StatelessWidget {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Game.Store>(builder: (context, storeModel, child) {
      List<Widget> storeItems = [];
      for (Game.BuildingSpec aSpec in storeModel.purchaseLevel.keys) {
        if (storeModel.purchaseLevel[aSpec]! > 0) {
          storeItems.add(StoreItem(aSpec));
        }
      }

      return ListView(scrollDirection: Axis.horizontal, children: storeItems);
    });
  }
}

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
                Stack(children: [
                  Padding(
                      padding: const EdgeInsets.only(),
                      child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                              "../assets/images/${widget._buildingSpec.toString().split('.').last}.png"))),
                  HighlightedText(
                      ((storeModel.purchaseLevel[_buildingSpec] ?? 0) > 0
                          ? storeModel.purchaseLevel[_buildingSpec].toString()
                          : ""))
                ]),
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
                            padding: const EdgeInsets.only(left: 15, top: 10),
                            child: Text(
                                (widget._buildingSpec.cost[aCost]! *
                                        pow(
                                            2,
                                            storeModel.purchaseLevel[
                                                    widget._buildingSpec]! -
                                                1))
                                    .toString()
                                    .split('.')
                                    .last,
                                style: Theme.of(context).textTheme.bodyLarge),
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
    return Consumer<Game.DetailsModel>(builder: (context, detailsModel, child) {
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
                  style: Theme.of(context).textTheme.bodyLarge),
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
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: Text("Total Mined: 223k",
                            style: Theme.of(context).textTheme.bodySmall),
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
                            child: (detailsModel.selectedBuilding!.paused)
                                ? const Text('Play')
                                : const Text('Pause')),
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
    return Consumer<Game.DetailsModel>(builder: (context, detailsModel, child) {
      String imageURL =
          '../assets/images/${detailsModel.selectedBuilding?.imageName}';

      return SizedBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Text(
                utils.prettyBuildingNames(detailsModel.selectedBuilding),
                style: Theme.of(context).textTheme.bodyMedium),
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
                      child: Text(
                          "Rate: ${detailsModel.selectedBuilding?.level}",
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0, top: 5),
                      child: Text("Total made: 223k",
                          style: Theme.of(context).textTheme.bodySmall),
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
                            for (var aFacCost in detailsModel.selectedBuilding!
                                .buildingSpec.recipe.cost.keys)
                              Stack(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),

                                      // height: 50,
                                      // width: 50,
                                      child: Image.asset(
                                          "../assets/images/${aFacCost.toString().split('.').last}.png")),
                                  HighlightedText(detailsModel.selectedBuilding!
                                      .buildingSpec.recipe.cost[aFacCost]
                                      .toString())
                                ],
                              )
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
                                "${detailsModel.selectedBuilding!.buildingSpec.recipe.duration.toString()} s",
                                style: Theme.of(context).textTheme.bodySmall)
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var aFacProduct in detailsModel
                                .selectedBuilding!
                                .buildingSpec
                                .recipe
                                .products
                                .keys)
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),

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
                          icon: (detailsModel.selectedBuilding!.paused)
                              ? const Icon(Icons.play_arrow)
                              : const Icon(Icons.pause),
                          tooltip: (detailsModel.selectedBuilding!.paused)
                              ? 'Play'
                              : 'Pause',
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
        ]),
      );
    });
  }
}

class LabView extends StatefulWidget {
  const LabView({super.key});

  @override
  State<LabView> createState() => _LabViewState();
}

class _LabViewState extends State<LabView> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 60,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory_sharp),
            label: 'Production',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_business_outlined),
            selectedIcon: Icon(Icons.add_business),
            label: 'Buildings',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Upgrades',
          ),
        ],
      ),
      body: [
        Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: FactoryView(),
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: ResearchView(),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
      ][currentPageIndex],
    );
  }
}

class ResearchView extends StatelessWidget {
  const ResearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Game.Store>(builder: (context, storeModel, child) {
      List<Widget> researchItems = [];
      for (Game.BuildingSpec aSpec in storeModel.purchaseLevel.keys) {
        researchItems.add(ResearchItem(aSpec));
      }

      return ListView(
          scrollDirection: Axis.horizontal, children: researchItems);
    });
  }
}

class ResearchItem extends StatefulWidget {
  Game.BuildingSpec _buildingSpec;

  ResearchItem(this._buildingSpec, {super.key});

  @override
  State<ResearchItem> createState() => _ResearchItemState(_buildingSpec);
}

class _ResearchItemState extends State<ResearchItem> {
  Game.BuildingSpec _buildingSpec;

  _ResearchItemState(this._buildingSpec);

  @override
  Widget build(BuildContext context) {
    // ${material.toString().split('.').last
    print(widget._buildingSpec.toString().split('.').last);
    Map<Game.Material, double> costs = storeModel.getCostOfUpgrade(
        _buildingSpec, storeModel.purchaseLevel[_buildingSpec] ?? 1);
    String overlayIcon = (storeModel.purchaseLevel[_buildingSpec] ?? 0) == 0
        ? "unlock.png"
        : "upgrade.png";

    return GestureDetector(
        onTap: () {
          storeModel.handleTechBuildingBuy(_buildingSpec);
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Text(
                          utils.prettyBuildingSpecNames(widget._buildingSpec),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall),
                    ),
                  ),
                ),
                Center(
                  child: Stack(children: [
                    SizedBox(height: 80, width: 80, child: Image.asset(
                        //todo make these show upgrade overlay with level update or unlock symbol based on level
                        "../assets/images/${widget._buildingSpec.toString().split('.').last}.png")),
                    Row(
                      children: [
                        SizedBox(height: 40, width: 40, child: Image.asset(
                            //todo make these show upgrade overlay with level update or unlock symbol based on level
                            "../assets/images/$overlayIcon")),
                        HighlightedText(
                            ((storeModel.purchaseLevel[_buildingSpec] ?? 0) > 0
                                ? (storeModel.purchaseLevel[_buildingSpec]! + 1)
                                    .toString()
                                : ""))
                        // Text("2", style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ]),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var aCost in costs.keys)
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
                                (costs[aCost] ?? 0).toString().split('.').last,
                                style: Theme.of(context).textTheme.bodySmall),
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

class HighlightedText extends StatelessWidget {
  String textToShow = "";
  HighlightedText(this.textToShow, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          textToShow,
          style: TextStyle(
            fontSize: 20,
            decoration: TextDecoration.none,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.blue,
          ),
        ),
        // Solid text as fill.
        Text(
          textToShow,
          style: TextStyle(
            fontSize: 20,
            decoration: TextDecoration.none,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
//todo add numbers to factory render 
//todo update the details view when a merge happens to show the new rate 
//todo make a warning when construction of building through research cost will exceed storage 
//todo progress bar ends a little too early 