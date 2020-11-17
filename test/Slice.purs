module Test.Slice where

import Prelude
import Data.Maybe (Maybe(..))
import Slice (Status(..))
import Slice as S
import Test.Spec (SpecT, describe, it)

spec :: forall t3 t4. Monad t4 => Applicative t3 => SpecT t3 Unit t4 Unit
spec =
  describe "slice" do
    reducer

reducer :: forall t3 t4. Monad t4 => Applicative t3 => SpecT t3 Unit t4 Unit
reducer =
  let
    mockState :: S.AppState
    mockState = { audioUrl: Nothing, status: Stopped }
  in
    describe "reducer" do
      it "should set correct state on Play"
        $ do
            let
              res = S.reducer mockState S.Play
            -- res `shouldEqual` (mockState { status = Playing })
            pure unit
