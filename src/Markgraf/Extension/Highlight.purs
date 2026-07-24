module Markgraf.Extension.Highlight (highlightHtml) where

import Prelude

import Data.Array as Array
import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Data.String.CodeUnits as CU

highlightHtml :: String -> String
highlightHtml source = foldMap renderTok (tokenize source)

renderTok :: { kind :: TokKind, text :: String } -> String
renderTok { kind, text } = case kind of
  TPlain -> escape text
  _ -> "<span class=\"" <> tokClass kind <> "\">" <> escape text <> "</span>"

escape :: String -> String
escape = replaceAll (Pattern "&") (Replacement "&amp;")
     >>> replaceAll (Pattern "<") (Replacement "&lt;")
     >>> replaceAll (Pattern ">") (Replacement "&gt;")

data TokKind
  = TKeyword
  | TOperator
  | TString
  | TNumber
  | TComment
  | TBrace
  | TIdent
  | TPlain

derive instance Eq TokKind

tokClass :: TokKind -> String
tokClass TKeyword  = "mg-tok-keyword"
tokClass TOperator = "mg-tok-op"
tokClass TString   = "mg-tok-string"
tokClass TNumber   = "mg-tok-number"
tokClass TComment  = "mg-tok-comment"
tokClass TBrace    = "mg-tok-brace"
tokClass TIdent    = "mg-tok-ident"
tokClass TPlain    = "mg-tok-plain"

tokenize :: String -> Array { kind :: TokKind, text :: String }
tokenize input = fuse (go 0 [])
  where
  n = CU.length input

  go i acc
    | i >= n = acc
    | otherwise = case matchAt i of
        { tok: Just t, next } -> go next (acc <> [ t ])
        { next: _ } ->
          let ch = fromMaybe "" (CU.singleton <$> CU.charAt i input)
          in go (i + 1) (acc <> [ { kind: TPlain, text: ch } ])

  matchAt i = case tryComment i of
    Just t -> { tok: Just t, next: i + CU.length t.text }
    Nothing -> case tryString i of
      Just t -> { tok: Just t, next: i + CU.length t.text }
      Nothing -> case tryOperator i of
        Just t -> { tok: Just t, next: i + CU.length t.text }
        Nothing -> case tryBrace i of
          Just t -> { tok: Just t, next: i + CU.length t.text }
          Nothing -> case tryPlusKw i of
            Just t -> { tok: Just t, next: i + CU.length t.text }
            Nothing -> case tryNumber i of
              Just t -> { tok: Just t, next: i + CU.length t.text }
              Nothing -> case tryIdent i of
                Just t -> { tok: Just t, next: i + CU.length t.text }
                Nothing -> { tok: Nothing, next: i + 1 }

  suffix i = CU.drop i input

  tryComment i = do
    let s = suffix i
    pref <- if startsWith "//" s then Just "//"
            else if startsWith "#" s then Just "#"
            else Nothing
    let line = takeWhileStr (\c -> c /= '\n') (CU.drop (CU.length pref) s)
    pure { kind: TComment, text: pref <> line }

  tryString i = do
    let s = suffix i
    _ <- if startsWith "\"" s then Just unit else Nothing
    let body = takeString (CU.drop 1 s)
    pure { kind: TString, text: "\"" <> body }

  takeString s = walk 0
    where
    len = CU.length s
    walk k
      | k >= len = CU.take k s
      | otherwise = case CU.charAt k s of
          Just '\\' -> walk (k + 2)
          Just '"' -> CU.take (k + 1) s
          _ -> walk (k + 1)

  tryOperator i = do
    let s = suffix i
    if startsWith "<-->" s then Just { kind: TOperator, text: "<-->" }
    else if startsWith "<->" s then Just { kind: TOperator, text: "<->" }
    else if startsWith "-->" s then Just { kind: TOperator, text: "-->" }
    else if startsWith "->" s then Just { kind: TOperator, text: "->" }
    else if startsWith "<-" s then Just { kind: TOperator, text: "<-" }
    else Nothing

  tryBrace i = case CU.charAt i input of
    Just '{' -> Just { kind: TBrace, text: "{" }
    Just '}' -> Just { kind: TBrace, text: "}" }
    _ -> Nothing

  tryPlusKw i = do
    let s = suffix i
    _ <- if startsWith "+" s then Just unit else Nothing
    let rest = takeWhileStr isIdentChar (CU.drop 1 s)
        full = "+" <> rest
    if rest == "node" || rest == "edge" || rest == "group"
      then Just { kind: TKeyword, text: full }
      else Nothing

  tryNumber i = do
    let s = suffix i
    _ <- case CU.charAt 0 s of
      Just c | isDigit c -> Just unit
      _ -> Nothing
    let whole = takeWhileStr isDigit s
        afterWhole = CU.drop (CU.length whole) s
        frac =
          if startsWith "." afterWhole
            then "." <> takeWhileStr isDigit (CU.drop 1 afterWhole)
            else ""
    pure { kind: TNumber, text: whole <> frac }

  tryIdent i = do
    let s = suffix i
    _ <- case CU.charAt 0 s of
      Just c | isIdentStart c -> Just unit
      _ -> Nothing
    let word = takeWhileStr isIdentChar s
        kind = if isKeyword word then TKeyword else TIdent
    pure { kind, text: word }

  isKeyword w =
    w == "seed" || w == "frame" || w == "par"
      || w == "chain" || w == "group" || w == "layout"

  fuse arr = fuseGo arr []

  fuseGo xs acc = case Array.uncons xs of
    Nothing -> acc
    Just { head: x, tail } -> case Array.unsnoc acc of
      Just { init, last } | last.kind == TPlain && x.kind == TPlain ->
        fuseGo tail (init <> [ { kind: TPlain, text: last.text <> x.text } ])
      _ -> fuseGo tail (acc <> [ x ])

startsWith :: String -> String -> Boolean
startsWith p s = CU.take (CU.length p) s == p

takeWhileStr :: (Char -> Boolean) -> String -> String
takeWhileStr pred s = CU.take (countMatching 0) s
  where
  n = CU.length s
  countMatching k
    | k >= n = k
    | otherwise = case CU.charAt k s of
        Just c | pred c -> countMatching (k + 1)
        _ -> k

isDigit :: Char -> Boolean
isDigit c = c >= '0' && c <= '9'

isIdentStart :: Char -> Boolean
isIdentStart c =
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'

isIdentChar :: Char -> Boolean
isIdentChar c = isIdentStart c || isDigit c || c == '-'
