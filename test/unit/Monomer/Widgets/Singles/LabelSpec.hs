module Monomer.Widgets.Singles.LabelSpec (spec) where

import Control.Lens ((&), (^.), (.~))
import Data.Text (Text)
import Test.Hspec

import qualified Data.Sequence as Seq
import qualified Data.Text as T

import Monomer.Core
import Monomer.Core.Combinators
import Monomer.Event
import Monomer.Graphics
import Monomer.TestUtil
import Monomer.Widgets.Singles.Label

import qualified Monomer.Lens as L

spec :: Spec
spec = describe "Label" $ do
  getSizeReq
  getSizeReqMulti
  getSizeReqMultiKeepSpaces
  getSizeReqMultiMaxLines
  getSizeReqMerge
  resize

getSizeReq :: Spec
getSizeReq = describe "getSizeReq" $ do
  it "should return width = Fixed 100" $
    sizeReqW `shouldBe` fixedSize 100

  it "should return height = Fixed 20" $
    sizeReqH `shouldBe` fixedSize 20

  it "should return width = Flex 120 1" $
    sizeReq2W `shouldBe` flexSize 120 1

  it "should return height = Flex 20 2" $
    sizeReq2H `shouldBe` flexSize 20 2

  where
    wenv = mockWenv ()
    lblNode = label "Test label"
    lblNode2 = label_ "Test label 2" [resizeFactorW 1, resizeFactorH 2]
    (sizeReqW, sizeReqH) = nodeGetSizeReq wenv lblNode
    (sizeReq2W, sizeReq2H) = nodeGetSizeReq wenv lblNode2

getSizeReqMulti :: Spec
getSizeReqMulti = describe "getSizeReq" $ do
  it "should return width = Fixed 50" $
    sizeReqW `shouldBe` fixedSize 50

  it "should return height = Flex 60 1" $
    sizeReqH `shouldBe` flexSize 60 1

  where
    wenv = mockWenv ()
    lblNode = label_ "Line    line    line" [multiLine, trimSpaces] `style` [width 50]
    (sizeReqW, sizeReqH) = nodeGetSizeReq wenv lblNode

getSizeReqMultiKeepSpaces :: Spec
getSizeReqMultiKeepSpaces = describe "getSizeReq" $ do
  it "should return width = Max 50 1" $
    sizeReqW `shouldBe` maxSize 50 1

  it "should return height = Flex 100 1" $
    sizeReqH `shouldBe` flexSize 100 1

  where
    wenv = mockWenv ()
    caption = "Line    line    line"
    lblNode = label_ caption [multiLine, trimSpaces_ False] `style` [maxWidth 50]
    (sizeReqW, sizeReqH) = nodeGetSizeReq wenv lblNode

getSizeReqMultiMaxLines :: Spec
getSizeReqMultiMaxLines = describe "getSizeReq" $ do
  it "should return width = Max 50 1" $
    sizeReqW `shouldBe` maxSize 50 1

  it "should return height = Flex 80 1" $
    sizeReqH `shouldBe` flexSize 80 1

  where
    wenv = mockWenv ()
    caption = "Line    line    line    line    line"
    lblNode = label_ caption [multiLine, trimSpaces_ False, maxLines 4] `style` [maxWidth 50]
    (sizeReqW, sizeReqH) = nodeGetSizeReq wenv lblNode

getSizeReqMerge :: Spec
getSizeReqMerge = describe "getSizeReqMerge" $ do
  it "should return width = Fixed 320" $
    sizeReqW `shouldBe` fixedSize 320

  it "should return height = Fixed 20" $
    sizeReqH `shouldBe` fixedSize 20

  it "should return width = Fixed 600" $
    sizeReq2W `shouldBe` fixedSize 600

  it "should return height = Fixed 20" $
    sizeReq2H `shouldBe` fixedSize 20

  where
    renderer = mockRenderer {
      computeTextSize = mockTextSize Nothing,
      computeGlyphsPos = mockGlyphsPos Nothing
    }
    wenv = mockWenvEvtUnit ()
      & L.renderer .~ renderer
    lblNode = nodeInit wenv (label "Test Label")
    lblNode2 = label "Test Label" `style` [textSize 60]
    lblRes = widgetMerge (lblNode2 ^. L.widget) wenv lblNode2 lblNode
    WidgetResult lblMerged _ = lblRes
    lblInfo = lblNode ^. L.info
    mrgInfo = lblMerged ^. L.info
    (sizeReqW, sizeReqH) = (lblInfo ^. L.sizeReqW, lblInfo ^. L.sizeReqH)
    (sizeReq2W, sizeReq2H) = (mrgInfo ^. L.sizeReqW, mrgInfo ^. L.sizeReqH)

resize :: Spec
resize = describe "resize" $ do
  it "should resize single line in a single step" $
    reqsSingle `shouldBe` Seq.Empty

  it "should resize multi line in two steps" $
    reqsMulti `shouldBe` Seq.singleton ResizeWidgets

  where
    wenv = mockWenvEvtUnit ()
    vp = Rect 0 0 640 480
    single = label "Test label"
    resSingle = widgetResize (single ^. L.widget) wenv single vp
    reqsSingle = resSingle ^. L.requests
    multi = label_ "Test label" [multiLine]
    resMulti = widgetResize (multi ^. L.widget) wenv multi vp
    reqsMulti = resMulti ^. L.requests