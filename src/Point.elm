module Point exposing (Point, decoder, distance, point, x, y)

import Json.Decode


type alias Point =
    ( Int, Int )


point : Int -> Int -> Point
point =
    Tuple.pair


decoder : Json.Decode.Decoder Point
decoder =
    Json.Decode.map2 point
        (Json.Decode.field "x" Json.Decode.int)
        (Json.Decode.field "y" Json.Decode.int)


squared : number -> number
squared num =
    num * num


distance : Point -> Point -> Float
distance ( x0, y0 ) ( x1, y1 ) =
    (sqrt << toFloat)
        (squared (x0 - x1) + squared (y0 - y1))


x : Point -> Int
x =
    Tuple.first


y : Point -> Int
y =
    Tuple.second
