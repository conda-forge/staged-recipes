-- Ensure we don't expose any unfoldings to guarantee quick rebuilds
{-# OPTIONS_GHC -O0 #-}

module UserSettings (
    userFlavours, userPackages, userDefaultFlavour,
    verboseCommand, buildProgressColour, successColour, finalStage
    ) where

import Flavour.Type
import Expression
import {-# SOURCE #-} Settings.Default

-- | Build only Stage1 cross-compiler (not Stage1Only = True, but finalStage = Stage1)
finalStage :: Stage
finalStage = Stage1

-- | Use quick-cross flavour as default for cross-compilation
userDefaultFlavour :: String
userDefaultFlavour = "quick-cross"

-- | User-defined build flavours
userFlavours :: [Flavour]
userFlavours = []

-- | Add user-defined packages if needed
userPackages :: [Package]
userPackages = []

-- | Enable verbose output for debugging
verboseCommand :: Predicate
verboseCommand = do
    verbosity <- expr getVerbosity
    return $ verbosity >= Verbose

-- | Build progress color
buildProgressColour :: BuildProgressColour
buildProgressColour = mkBuildProgressColour (Dull Magenta)

-- | Success color
successColour :: SuccessColour
successColour = mkSuccessColour (Dull Green)
