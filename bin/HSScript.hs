#! /usr/bin/env nix-shell
#! nix-shell -p "pkgs.haskell.packages.ghc921.ghcWithPackages (p: [p.ansi-terminal])"
#! nix-shell -i "runhaskell"

import qualified Data.Text.IO as T
import System.Console.ANSI

main :: IO ()
main = do
    line <- T.getLine
    setSGR [SetColor Foreground Vivid Green]
    setSGR [SetColor Background Dull Blue]
    T.putStrLn line
    setSGR [Reset]
