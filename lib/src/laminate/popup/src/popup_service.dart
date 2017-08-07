// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';

import '../../../css/acux/zindexer.dart';
import '../../../utils/browser/events/events.dart';
import '../../enums/alignment.dart';
import '../../overlay/module.dart';
import '../../overlay/overlay.dart';
import './popup_ref.dart';
import './popup_state.dart';

/// A token representing a [List] of [RelativePosition]s to use when popup auto
/// positioning is set (`enforceSpaceConstraints`) but no custom positions
/// (`preferredPositions`) are set.
const OpaqueToken defaultPopupPositions =
    const OpaqueToken('defaultPopupPositions');

@Injectable()
class PopupService {
  final List<RelativePosition> _defaultPreferredPositions;
  final OverlayService _overlayService;
  final ZIndexer _zIndexer;
  final NgZone _ngZone;
  final bool _useRepositionLoop;

  PopupService(
      @Inject(defaultPopupPositions) this._defaultPreferredPositions,
      this._overlayService,
      this._zIndexer,
      this._ngZone,
      @Inject(overlayRepositionLoop) this._useRepositionLoop);

  /// Creates a managed overlay pane within the registered container.
  ///
  /// If [initialState] is specified, configuration for the overlay is setup
  /// immediately on creation, versus waiting for the future to resolve.
  ///
  /// The returned future completes with a reference to the popup.
  Future<PopupRef> createPopupRef(
      {PopupState initialState, Future<PopupRef> parent}) {
    return _overlayService.createOverlayRef().then((overlayRef) {
      return new PopupRefImpl(overlayRef, _zIndexer, _ngZone,
          defaultPreferredPositions: _defaultPreferredPositions,
          state: initialState,
          parent: parent,
          viewportFn: _measureViewportSize,
          useRepositionLoop: _useRepositionLoop);
    });
  }

  /// Creates a managed overlay pane within the registered container.
  ///
  /// If [initialState] is not specified, defaults to `new PopupState()`.
  ///
  /// Returns instantly with a reference to the popup.
  PopupRef createPopupRefSync({PopupState initialState, PopupRef parent}) {
    return new PopupRefImpl(
        _overlayService.createOverlayRefSync(), _zIndexer, _ngZone,
        defaultPreferredPositions: _defaultPreferredPositions,
        state: initialState,
        parent: new Future<PopupRef>.value(parent),
        viewportFn: _measureViewportSize,
        useRepositionLoop: _useRepositionLoop);
  }

  Future<Rectangle<num>> _measureViewportSize() =>
      _overlayService.measureContainer();

  /// Returns a stream that fires when the document is pressed or when focus is
  /// changed *but* [popup] is not in the parent chain of elements that received
  /// the event.
  Stream<Event> onTriggerOutsideOf(PopupRef popup) {
    assert(popup != null);

    // Get a handle to the underlying element/elementRef.
    PopupRefImpl popupInternal = popup;
    var overlayElement = popupInternal.overlay.overlayElement;
    return triggersOutside(overlayElement);
  }

  /// Whether an event triggered inside of a given popup.
  bool isTriggerInside(Event e, PopupRef popup) {
    // Get a handle to the underlying element/elementRef.
    PopupRefImpl popupInternal = popup;
    var overlayElement = popupInternal.overlay.overlayElement;
    return isParentOf(overlayElement, e.target as Node);
  }

  /// Get a handle to the underlying element/elementRef.
  Element getContainerElement(PopupRef popup) {
    PopupRefImpl popupInternal = popup;
    return popupInternal.overlay.overlayElement;
  }
}
