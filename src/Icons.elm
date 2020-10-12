module Icons exposing (..)

import Element exposing (Element)
import Svg
import Svg.Attributes
import Utils



-- Mono icons
-- https://icons.mono.company/


leftChevron : Element.Color -> Element msg
leftChevron color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.width "24"
            , Svg.Attributes.height "24"
            , Svg.Attributes.viewBox "0 0 24 24"
            ]
            [ Svg.path
                [ Svg.Attributes.fillRule "evenodd"
                , Svg.Attributes.clipRule "evenodd"
                , Svg.Attributes.d "M14.7071 5.29289C15.0976 5.68342 15.0976 6.31658 14.7071 6.70711L9.41421 12L14.7071 17.2929C15.0976 17.6834 15.0976 18.3166 14.7071 18.7071C14.3166 19.0976 13.6834 19.0976 13.2929 18.7071L7.29289 12.7071C6.90237 12.3166 6.90237 11.6834 7.29289 11.2929L13.2929 5.29289C13.6834 4.90237 14.3166 4.90237 14.7071 5.29289Z"
                , Svg.Attributes.fill <| Utils.toHex color
                ]
                []
            ]


rightChevron : Element.Color -> Element msg
rightChevron color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.width "24"
            , Svg.Attributes.height "24"
            , Svg.Attributes.viewBox "0 0 24 24"
            ]
            [ Svg.path
                [ Svg.Attributes.fillRule "evenodd"
                , Svg.Attributes.clipRule "evenodd"
                , Svg.Attributes.d "M9.29289 18.7071C8.90237 18.3166 8.90237 17.6834 9.29289 17.2929L14.5858 12L9.29289 6.70711C8.90237 6.31658 8.90237 5.68342 9.29289 5.29289C9.68342 4.90237 10.3166 4.90237 10.7071 5.29289L16.7071 11.2929C17.0976 11.6834 17.0976 12.3166 16.7071 12.7071L10.7071 18.7071C10.3166 19.0976 9.68342 19.0976 9.29289 18.7071Z"
                , Svg.Attributes.fill <| Utils.toHex color
                ]
                []
            ]


moon : Element.Color -> Element msg
moon color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.width "24"
            , Svg.Attributes.height "24"
            , Svg.Attributes.viewBox "0 0 24 24"
            ]
            [ Svg.path
                [ Svg.Attributes.fillRule "evenodd"
                , Svg.Attributes.clipRule "evenodd"
                , Svg.Attributes.d "M9.36077 3.29291C9.6659 3.59803 9.74089 4.06445 9.54678 4.44984C9.04068 5.4547 8.75521 6.59035 8.75521 7.79557C8.75521 11.9097 12.0903 15.2448 16.2044 15.2448C17.4097 15.2448 18.5453 14.9593 19.5502 14.4532C19.9356 14.2591 20.402 14.3341 20.7071 14.6392C21.0122 14.9444 21.0872 15.4108 20.8931 15.7962C19.3396 18.8806 16.1428 21 12.4492 21C7.23056 21 3 16.7695 3 11.5508C3 7.85719 5.11941 4.6604 8.20384 3.1069C8.58923 2.91279 9.05565 2.98778 9.36077 3.29291ZM6.8217 6.6696C5.68637 7.97742 5 9.68431 5 11.5508C5 15.6649 8.33513 19 12.4492 19C14.3157 19 16.0226 18.3136 17.3304 17.1783C16.9611 17.2222 16.5853 17.2448 16.2044 17.2448C10.9858 17.2448 6.75521 13.0142 6.75521 7.79557C6.75521 7.41472 6.77779 7.03896 6.8217 6.6696Z"
                , Svg.Attributes.fill <| Utils.toHex color
                ]
                []
            ]


sun : Element.Color -> Element msg
sun color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.width "24"
            , Svg.Attributes.height "24"
            , Svg.Attributes.viewBox "0 0 24 24"
            ]
            [ Svg.path
                [ Svg.Attributes.fillRule "evenodd"
                , Svg.Attributes.clipRule "evenodd"
                , Svg.Attributes.d "M12 2C12.5523 2 13 2.44772 13 3V4C13 4.55228 12.5523 5 12 5C11.4477 5 11 4.55228 11 4V3C11 2.44772 11.4477 2 12 2ZM19.0711 4.92893C19.4616 5.31945 19.4616 5.95261 19.0711 6.34314L18.364 7.05025C17.9735 7.44077 17.3403 7.44077 16.9498 7.05025C16.5593 6.65972 16.5593 6.02656 16.9498 5.63603L17.6569 4.92893C18.0474 4.5384 18.6806 4.5384 19.0711 4.92893ZM4.92893 4.92893C5.31945 4.5384 5.95262 4.5384 6.34314 4.92893L7.05025 5.63603C7.44077 6.02656 7.44077 6.65972 7.05025 7.05025C6.65972 7.44077 6.02656 7.44077 5.63603 7.05025L4.92893 6.34314C4.5384 5.95262 4.5384 5.31945 4.92893 4.92893ZM12 8C9.79086 8 8 9.79086 8 12C8 14.2091 9.79086 16 12 16C14.2091 16 16 14.2091 16 12C16 9.79086 14.2091 8 12 8ZM6 12C6 8.68629 8.68629 6 12 6C15.3137 6 18 8.68629 18 12C18 15.3137 15.3137 18 12 18C8.68629 18 6 15.3137 6 12ZM2 12C2 11.4477 2.44772 11 3 11H4C4.55228 11 5 11.4477 5 12C5 12.5523 4.55228 13 4 13H3C2.44772 13 2 12.5523 2 12ZM19 12C19 11.4477 19.4477 11 20 11H21C21.5523 11 22 11.4477 22 12C22 12.5523 21.5523 13 21 13H20C19.4477 13 19 12.5523 19 12ZM5.63603 16.9497C6.02656 16.5592 6.65972 16.5592 7.05025 16.9497C7.44077 17.3403 7.44077 17.9734 7.05025 18.364L6.34314 19.0711C5.95262 19.4616 5.31945 19.4616 4.92893 19.0711C4.5384 18.6805 4.5384 18.0474 4.92893 17.6568L5.63603 16.9497ZM16.9498 18.364C16.5593 17.9734 16.5593 17.3403 16.9498 16.9497C17.3403 16.5592 17.9735 16.5592 18.364 16.9497L19.0711 17.6568C19.4616 18.0474 19.4616 18.6805 19.0711 19.0711C18.6806 19.4616 18.0474 19.4616 17.6569 19.0711L16.9498 18.364ZM12 19C12.5523 19 13 19.4477 13 20V21C13 21.5523 12.5523 22 12 22C11.4477 22 11 21.5523 11 21V20C11 19.4477 11.4477 19 12 19Z"
                , Svg.Attributes.fill <| Utils.toHex color
                ]
                []
            ]


stop : Element.Color -> Element msg
stop color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.width "24"
            , Svg.Attributes.height "24"
            , Svg.Attributes.viewBox "0 0 24 24"
            ]
            [ Svg.path
                [ Svg.Attributes.fillRule "evenodd"
                , Svg.Attributes.clipRule "evenodd"
                , Svg.Attributes.d "M5 7C5 5.89543 5.89543 5 7 5H17C18.1046 5 19 5.89543 19 7V17C19 18.1046 18.1046 19 17 19H7C5.89543 19 5 18.1046 5 17V7ZM17 7L7 7V17H17V7Z"
                , Svg.Attributes.fill <| Utils.toHex color
                ]
                []
            ]


grid : Element.Color -> Element msg
grid color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.width "24"
            , Svg.Attributes.height "24"
            , Svg.Attributes.viewBox "0 0 24 24"
            ]
            [ Svg.path
                [ Svg.Attributes.fillRule "evenodd"
                , Svg.Attributes.clipRule "evenodd"
                , Svg.Attributes.d "M3 5C3 3.89543 3.89543 3 5 3H9C10.1046 3 11 3.89543 11 5V9C11 10.1046 10.1046 11 9 11H5C3.89543 11 3 10.1046 3 9V5ZM9 5H5V9H9V5ZM13 5C13 3.89543 13.8954 3 15 3H19C20.1046 3 21 3.89543 21 5V9C21 10.1046 20.1046 11 19 11H15C13.8954 11 13 10.1046 13 9V5ZM19 5H15V9H19V5ZM3 15C3 13.8954 3.89543 13 5 13H9C10.1046 13 11 13.8954 11 15V19C11 20.1046 10.1046 21 9 21H5C3.89543 21 3 20.1046 3 19V15ZM9 15H5V19H9V15ZM13 15C13 13.8954 13.8954 13 15 13H19C20.1046 13 21 13.8954 21 15V19C21 20.1046 20.1046 21 19 21H15C13.8954 21 13 20.1046 13 19V15ZM19 15H15V19H19V15Z"
                , Svg.Attributes.fill <| Utils.toHex color
                ]
                []
            ]
