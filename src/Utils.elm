module Utils exposing (toCss, toHex)

import Element


toCss : Element.Color -> String
toCss color =
    let
        { red, green, blue } =
            Element.toRgb color

        to255 c =
            min
                ((c * 255 |> floor)
                    -- I add one because otherwise the background color ends up being different
                    -- when rendered with Elm UI or with this function.
                    + 1
                )
                255
    in
    "rgb("
        ++ String.fromInt (to255 red)
        ++ ", "
        ++ String.fromInt (to255 green)
        ++ ", "
        ++ String.fromInt (to255 blue)
        ++ ")"


toHex : Element.Color -> String
toHex color =
    let
        { red, green, blue } =
            Element.toRgb color
    in
    "#" ++ floatToHex red ++ floatToHex green ++ floatToHex blue


floatToHex : Float -> String
floatToHex float =
    let
        int =
            float * 255 |> floor
    in
    String.fromChar (hexDigit (int // 16))
        ++ String.fromChar (hexDigit (int |> modBy 16))


hexDigit : Int -> Char
hexDigit int =
    case int of
        0 ->
            '0'

        1 ->
            '1'

        2 ->
            '2'

        3 ->
            '3'

        4 ->
            '4'

        5 ->
            '5'

        6 ->
            '6'

        7 ->
            '7'

        8 ->
            '8'

        9 ->
            '9'

        10 ->
            'A'

        11 ->
            'B'

        12 ->
            'C'

        13 ->
            'D'

        14 ->
            'E'

        _ ->
            'F'
