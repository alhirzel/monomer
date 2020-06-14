{-# LANGUAGE FlexibleContexts #-}

module Monomer.Main.Util where

import Data.Maybe

import qualified Data.Sequence as Seq

import Monomer.Common.Geometry
import Monomer.Event.Util
import Monomer.Main.Types
import Monomer.Widget.PathContext
import Monomer.Widget.Types

initMonomerContext :: s -> Rect -> Bool -> Double -> MonomerContext s
initMonomerContext app winSize useHiDPI devicePixelRate = MonomerContext {
  _appContext = app,
  _windowSize = winSize,
  _useHiDPI = useHiDPI,
  _devicePixelRate = devicePixelRate,
  _inputStatus = defInputStatus,
  _focused = Seq.empty,
  _latestHover = Nothing,
  _widgetTasks = Seq.empty
}

findNextFocusable :: Path -> WidgetInstance s e -> Path
findNextFocusable currentFocus widgetRoot = fromMaybe rootFocus candidateFocus where
  ctxFocus = PathContext currentFocus currentFocus rootPath
  candidateFocus = _widgetNextFocusable (_instanceWidget widgetRoot) ctxFocus widgetRoot
  ctxRootFocus = PathContext rootPath rootPath rootPath
  rootFocus = fromMaybe currentFocus $ _widgetNextFocusable (_instanceWidget widgetRoot) ctxRootFocus widgetRoot

compose :: (Traversable t) => t (a -> a) -> a -> a
compose functions init = foldr (.) id functions init

bindIf :: (Monad m) => Bool -> (a -> m a) -> a -> m a
bindIf False _ value = return value
bindIf _ action value = action value