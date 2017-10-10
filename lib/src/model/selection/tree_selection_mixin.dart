// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:angular_components/src/model/selection/select.dart';
import 'package:angular_components/src/model/selection/selection_options.dart';
import 'package:meta/meta.dart';

/// A mixin created to support tree-based selection options.
///
/// When mixin this component, one should override the getHierarchyMap()
/// method in order for the functionality to work.
abstract class TreeSelectionMixin<T>
    implements Parent<T, List<OptionGroup<T>>> {
  /// Flatten all the OptionGroups of the tree into one long list.
  List<OptionGroup<T>> flatOptionGroup() {
    List<OptionGroup<T>> result = [];

    getHierarchyMap()
        .values
        .forEach((List<OptionGroup<T>> options) => result.addAll(options));

    return result;
  }

  /// Gets a flat list of T when given a parent of type T.
  List<T> allChildrenOf(T e) {
    List<T> allChildren = new List<T>();
    Queue<T> parentsToCheck = new Queue<T>();

    // To prevent an accidental circular reference
    Set<T> visited = new Set<T>();

    visited.add(e);
    parentsToCheck.add(e);

    Map<T, List<OptionGroup<T>>> hierarchyMap = getHierarchyMap();

    while (parentsToCheck.isNotEmpty) {
      T parent = parentsToCheck.removeFirst();

      hierarchyMap[parent].forEach((optionGroup) {
        optionGroup.toList().forEach((item) {
          if (!visited.contains(item)) {
            allChildren.add(item);
            if (hasChildren(item)) {
              parentsToCheck.add(item);
              visited.add(item);
            }
          }
        });
      });
    }

    return allChildren;
  }

  /// Returns the hierarchy map data of the tree.
  @protected
  Map<T, List<OptionGroup<T>>> getHierarchyMap() =>
      throw new UnimplementedError('getHierarchyMap() must be overriden.');

  /// Returns the parent of the given value
  @visibleForTesting
  T getParent(T value) => null;
}
