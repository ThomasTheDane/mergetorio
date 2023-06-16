// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import '../game.dart';

export 'color_schemes.dart';
export 'num_utils.dart';

prettyFormat(double? n) {
  n ??= 0;
  return (n).toStringAsFixed(0);
  // return n.toStringAsFixed(n.toString());
  // var f = NumberFormat("###.0#", "en_US");
  // print(f.format(12.345));
}

String prettyNames(Material aMaterial) {
  if (aMaterial == Material.ironOre) {
    return "iron Ore";
  }
  if (aMaterial == Material.ironPlate) {
    return "iron Plate";
  }
  return "pretty not found";
}
