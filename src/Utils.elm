module Utils exposing (toHex)

import Element


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
