{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "console"
  , "effect"
  , "js-date"
  , "js-timers"
  , "psci-support"
  , "random"
  , "react-basic"
  , "react-basic-dom"
  , "react-basic-hooks"
  , "generics-rep"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
