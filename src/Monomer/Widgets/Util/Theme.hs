{-# LANGUAGE RankNTypes #-}

module Monomer.Widgets.Util.Theme where

import Control.Lens (Lens', (&), (^.), (^?), (.~), (?~), (<>~), non)
import Data.Default

import Monomer.Core

import qualified Monomer.Lens as L

themeEmptyOverlayColor :: WidgetEnv s e -> Style
themeEmptyOverlayColor wenv = collectThemeField wenv L.bgColor L.emptyOverlayColor

themeText :: WidgetEnv s e -> Style
themeText wenv = collectThemeField wenv L.text L.text

themeBtn :: WidgetEnv s e -> Style
themeBtn wenv = collectTheme wenv L.btnStyle

themeBtnMain :: WidgetEnv s e -> Style
themeBtnMain wenv = collectTheme wenv L.btnMainStyle

themeDialogFrame :: WidgetEnv s e -> Style
themeDialogFrame wenv = collectTheme wenv L.dialogFrameStyle

themeDialogTitle :: WidgetEnv s e -> Style
themeDialogTitle wenv = collectTheme wenv L.dialogTitleStyle

themeDialogBody :: WidgetEnv s e -> Style
themeDialogBody wenv = collectTheme wenv L.dialogBodyStyle

themeDialogButtons :: WidgetEnv s e -> Style
themeDialogButtons wenv = collectTheme wenv L.dialogButtonsStyle

collectThemeField
  :: WidgetEnv s e -> Lens' StyleState (Maybe t) -> Lens' ThemeState t -> Style
collectThemeField wenv fieldS fieldT = style where
  base = def :: Style
  basic = Just $ base ^. L.basic . non def
    & fieldS ?~ wenv ^. L.theme . L.basic . fieldT
  hover = Just $ base ^. L.hover . non def
    & fieldS ?~ wenv ^. L.theme . L.hover . fieldT
  focus = Just $ base ^. L.focus . non def
    & fieldS ?~ wenv ^. L.theme . L.focus . fieldT
  disabled = Just $ base ^. L.disabled . non def
    & fieldS ?~ wenv ^. L.theme . L.disabled . fieldT
  style = Style basic hover focus disabled

collectTheme :: WidgetEnv s e  -> Lens' ThemeState StyleState -> Style
collectTheme wenv fieldT = style where
  basic = Just $ wenv ^. L.theme . L.basic . fieldT
  hover = Just $ wenv ^. L.theme . L.hover . fieldT
  focus = Just $ wenv ^. L.theme . L.focus . fieldT
  disabled = Just $ wenv ^. L.theme . L.disabled . fieldT
  style = Style basic hover focus disabled