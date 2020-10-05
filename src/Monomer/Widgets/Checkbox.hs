{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Monomer.Widgets.Checkbox (
  CheckboxCfg,
  checkbox,
  checkbox_,
  checkboxV,
  checkboxV_,
  checkboxD_
) where

import Control.Lens (ALens', (&), (^.), (.~))
import Control.Monad
import Data.Default
import Data.Text (Text)

import Monomer.Core.BaseSingle
import Monomer.Core.BasicTypes
import Monomer.Core.Style
import Monomer.Core.StyleUtil (removeOuterBounds)
import Monomer.Core.Types
import Monomer.Core.Util
import Monomer.Event.Keyboard
import Monomer.Event.Types
import Monomer.Graphics.Drawing
import Monomer.Graphics.Types
import Monomer.Widgets.WidgetCombinators

data CheckboxCfg s e = CheckboxCfg {
  _ckcOnChange :: [Bool -> e],
  _ckcOnChangeReq :: [WidgetRequest s]
}

instance Default (CheckboxCfg s e) where
  def = CheckboxCfg {
    _ckcOnChange = [],
    _ckcOnChangeReq = []
  }

instance Semigroup (CheckboxCfg s e) where
  (<>) t1 t2 = CheckboxCfg {
    _ckcOnChange = _ckcOnChange t1 <> _ckcOnChange t2,
    _ckcOnChangeReq = _ckcOnChangeReq t1 <> _ckcOnChangeReq t2
  }

instance Monoid (CheckboxCfg s e) where
  mempty = def

instance OnChange (CheckboxCfg s e) Bool e where
  onChange fn = def {
    _ckcOnChange = [fn]
  }

instance OnChangeReq (CheckboxCfg s e) s where
  onChangeReq req = def {
    _ckcOnChangeReq = [req]
  }

checkboxWidth :: Double
checkboxWidth = 25

checkboxBorderW :: Double
checkboxBorderW = 2

checkbox :: ALens' s Bool -> WidgetInstance s e
checkbox field = checkbox_ field def

checkbox_ :: ALens' s Bool -> [CheckboxCfg s e] -> WidgetInstance s e
checkbox_ field config = checkboxD_ (WidgetLens field) config

checkboxV :: Bool -> (Bool -> e) -> WidgetInstance s e
checkboxV value handler = checkboxV_ value handler def

checkboxV_ :: Bool -> (Bool -> e) -> [CheckboxCfg s e] -> WidgetInstance s e
checkboxV_ value handler config = checkboxD_ (WidgetValue value) newConfig where
  newConfig = onChange handler : config

checkboxD_ :: WidgetData s Bool -> [CheckboxCfg s e] -> WidgetInstance s e
checkboxD_ widgetData configs = checkboxInstance where
  config = mconcat configs
  widget = makeCheckbox widgetData config
  checkboxInstance = (defaultWidgetInstance "checkbox" widget) {
    _wiFocusable = True
  }

makeCheckbox :: WidgetData s Bool -> CheckboxCfg s e -> Widget s e
makeCheckbox widgetData config = widget where
  widget = createSingle def {
    singleHandleEvent = handleEvent,
    singleGetSizeReq = getSizeReq,
    singleRender = render
  }

  handleEvent wenv target evt inst = case evt of
    Click (Point x y) _ -> Just $ resultReqsEvents clickReqs events inst
    KeyAction mod code KeyPressed
      | isSelectKey code -> Just $ resultReqsEvents reqs events inst
    _ -> Nothing
    where
      isSelectKey code = isKeyReturn code || isKeySpace code
      model = _weModel wenv
      value = widgetDataGet model widgetData
      newValue = not value
      events = fmap ($ newValue) (_ckcOnChange config)
      setValueReq = widgetDataSet widgetData newValue
      setFocusReq = SetFocus $ _wiPath inst
      reqs = setValueReq ++ _ckcOnChangeReq config
      clickReqs = setFocusReq : reqs

  getSizeReq wenv inst =
    (FixedSize checkboxWidth, FixedSize checkboxWidth)

  render renderer wenv inst = do
    renderCheckbox renderer config rarea fgColor

    when value $
      renderMark renderer config rarea fgColor
    where
      model = _weModel wenv
      style = activeStyle wenv inst
      value = widgetDataGet model widgetData
      rarea = removeOuterBounds style $ _wiRenderArea inst
      checkboxL = _rX rarea
      checkboxT = _rY rarea
      sz = min (_rW rarea) (_rH rarea)
      checkboxArea = Rect checkboxL checkboxT sz sz
      fgColor = instanceFgColor wenv inst

renderCheckbox :: Renderer -> CheckboxCfg s e -> Rect -> Color -> IO ()
renderCheckbox renderer config rect color = action where
  side = Just $ BorderSide checkboxBorderW color
  border = Border side side side side
  action = drawRectBorder renderer rect border Nothing

renderMark :: Renderer -> CheckboxCfg s e -> Rect -> Color -> IO ()
renderMark renderer config rect color = action where
  w = checkboxBorderW * 2
  newRect = subtractFromRect rect w w w w
  action = drawRect renderer newRect (Just color) Nothing