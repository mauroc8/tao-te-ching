port module Main exposing (main)

import AddissAndLombardo.TaoTeChing
import Array exposing (Array)
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Navigation
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Html.Attributes
import Json.Decode
import Maybe.Extra
import Spanish.TaoTeChing
import Svg
import Svg.Attributes
import TaoTeChing
import Task
import Time
import Url exposing (Url)



--- TRANSLATIONS


type Language
    = English EnglishTranslators
    | Spanish


type EnglishTranslators
    = StephenMitchell
    | AddissAndLombardo



--- To change the translation, change this constant and make a different build!


language : Language
language =
    English AddissAndLombardo


chapters : Array String
chapters =
    case language of
        English StephenMitchell ->
            TaoTeChing.chapters

        English AddissAndLombardo ->
            AddissAndLombardo.TaoTeChing.chapters

        Spanish ->
            Spanish.TaoTeChing.chapters



--- MAIN


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = RequestedUrl
        , onUrlChange = ChangedUrl
        }



--- MODEL


type alias Model =
    { view : View
    , navigationKey : Navigation.Key
    , theme : Theme
    , transition : Transition
    }


type View
    = Chapter Int
    | Grid Int


type Theme
    = Light
    | Dark


type Transition
    = FadeOut View
    | AboutToFadeIn
    | FadeIn


{-| Duration in msecs
-}
transitionDuration : number
transitionDuration =
    200


init : Json.Decode.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        chapterFromUrl =
            getChapterFromUrl url

        chapterFromFlags =
            getChapterFromFlags flags
    in
    ( { view =
            Maybe.Extra.or chapterFromUrl chapterFromFlags
                |> Maybe.withDefault 0
                |> Chapter
      , navigationKey =
            navKey
      , theme =
            getThemeFromFlags flags
      , transition =
            AboutToFadeIn
      }
    , case ( chapterFromUrl, chapterFromFlags ) of
        ( Nothing, Just chapter ) ->
            Navigation.replaceUrl navKey (chapterNumberToUrl chapter)

        _ ->
            Cmd.none
    )


getChapterFromUrl : Url -> Maybe Int
getChapterFromUrl url =
    url.fragment
        |> Maybe.andThen String.toInt
        |> Maybe.andThen
            (\int ->
                if int >= 1 && int <= Array.length chapters then
                    Just (int - 1)

                else
                    Nothing
            )


getChapterFromFlags : Json.Decode.Value -> Maybe Int
getChapterFromFlags value =
    value
        |> Json.Decode.decodeValue
            (Json.Decode.field "currentChapter" Json.Decode.int)
        |> Result.toMaybe


chapterNumberToUrl : Int -> String
chapterNumberToUrl chapterNumber =
    "#" ++ String.fromInt (chapterNumber + 1)


loadUrl : Url -> Model -> Model
loadUrl url model =
    { model | view = Chapter (getChapterFromUrl url |> Maybe.withDefault 0) }


getCurrentChapter : View -> Int
getCurrentChapter view_ =
    case view_ of
        Chapter currentChapter ->
            currentChapter

        Grid currentChapter ->
            currentChapter


withView : View -> Model -> Model
withView nextView model =
    { model | view = nextView }


withTransition : Transition -> Model -> Model
withTransition transition model =
    { model | transition = transition }


withTheme : Theme -> Model -> Model
withTheme theme model =
    { model | theme = theme }


toggleTheme : Theme -> Theme
toggleTheme theme =
    case theme of
        Light ->
            Dark

        Dark ->
            Light


themeToString : Theme -> String
themeToString theme =
    case theme of
        Light ->
            "light"

        Dark ->
            "dark"


getThemeFromFlags : Json.Decode.Value -> Theme
getThemeFromFlags value =
    value
        |> Json.Decode.decodeValue
            (Json.Decode.field "theme" Json.Decode.string)
        |> Result.map getThemeFromString
        |> Result.withDefault Light


getThemeFromString : String -> Theme
getThemeFromString string =
    case String.toLower string of
        "light" ->
            Light

        "dark" ->
            Dark

        _ ->
            Light


isGridView : View -> Bool
isGridView view_ =
    case view_ of
        Chapter _ ->
            False

        Grid _ ->
            True



--- UPDATE


type Msg
    = RequestedUrl UrlRequest
    | ChangedUrl Url
    | Pressed Button
    | BegunFadeOutTransition View Time.Posix
    | BegunFadeInTransition Time.Posix
    | EndedFadeOutTransition Time.Posix


type Button
    = PreviousChapter
    | NextChapter
    | SelectChapter
    | ToggleTheme
    | ChapterNumber Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestedUrl (Browser.Internal url) ->
            ( model
            , Navigation.pushUrl model.navigationKey (Url.toString url)
            )

        RequestedUrl (Browser.External string) ->
            ( model, Navigation.load string )

        ChangedUrl url ->
            ( loadUrl url model, Cmd.none )

        Pressed PreviousChapter ->
            changeChapter model.navigationKey (getCurrentChapter model.view - 1) model

        Pressed NextChapter ->
            changeChapter model.navigationKey (getCurrentChapter model.view + 1) model

        Pressed SelectChapter ->
            toggleChapterSelection model

        Pressed ToggleTheme ->
            ( model
                |> withTheme (toggleTheme model.theme)
            , saveTheme (toggleTheme model.theme |> themeToString)
            )

        Pressed (ChapterNumber chapterNumber) ->
            changeChapter model.navigationKey chapterNumber model

        BegunFadeOutTransition nextView _ ->
            ( model
                |> withView nextView
                |> withTransition (FadeOut model.view)
            , saveCurrentChapter (getCurrentChapter nextView)
            )

        BegunFadeInTransition _ ->
            ( model
                |> withTransition FadeIn
            , Cmd.none
            )

        EndedFadeOutTransition _ ->
            ( model
                |> withTransition AboutToFadeIn
            , Cmd.none
            )


toggleChapterSelection : Model -> ( Model, Cmd Msg )
toggleChapterSelection model =
    let
        nextView =
            case model.view of
                Chapter currentChapter ->
                    Grid currentChapter

                Grid currentChapter ->
                    Chapter currentChapter
    in
    ( model
    , startFadeOutTransition nextView
    )


changeChapter : Navigation.Key -> Int -> Model -> ( Model, Cmd Msg )
changeChapter navigationKey chapterNumber model =
    let
        currentChapter =
            getCurrentChapter model.view

        nextChapter =
            clamp 0 (Array.length chapters - 1) chapterNumber
    in
    if currentChapter /= nextChapter then
        ( model
        , Cmd.batch
            [ Navigation.pushUrl navigationKey (chapterNumberToUrl nextChapter)
            , startFadeOutTransition (Chapter nextChapter)
            ]
        )

    else if isGridView model.view then
        toggleChapterSelection model

    else
        ( model, Cmd.none )


startFadeOutTransition : View -> Cmd Msg
startFadeOutTransition nextView =
    Time.now
        |> Task.perform (BegunFadeOutTransition nextView)


port saveTheme : String -> Cmd msg


port saveCurrentChapter : Int -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.transition of
        FadeOut _ ->
            Time.every transitionDuration EndedFadeOutTransition

        AboutToFadeIn ->
            Browser.Events.onAnimationFrame BegunFadeInTransition

        _ ->
            Sub.none



--- VIEW


white : Element.Color
white =
    Element.rgb 0.95 0.95 0.95


black : Element.Color
black =
    Element.rgb 0.05 0.05 0.05


lightishGray : Element.Color
lightishGray =
    Element.rgb 0.7 0.7 0.7


lightGray : Element.Color
lightGray =
    Element.rgb 0.8 0.8 0.8


lighterGray : Element.Color
lighterGray =
    Element.rgb 0.9 0.9 0.9


darkishGray : Element.Color
darkishGray =
    Element.rgb 0.3 0.3 0.3


darkGray : Element.Color
darkGray =
    Element.rgb 0.2 0.2 0.2


darkerGray : Element.Color
darkerGray =
    Element.rgb 0.1 0.1 0.1


subtleishGray : Theme -> Element.Color
subtleishGray theme =
    case theme of
        Light ->
            lightishGray

        Dark ->
            darkishGray


subtleGray : Theme -> Element.Color
subtleGray theme =
    case theme of
        Light ->
            lightGray

        Dark ->
            darkGray


subtlerGray : Theme -> Element.Color
subtlerGray theme =
    case theme of
        Light ->
            lighterGray

        Dark ->
            darkerGray


strongishGray : Theme -> Element.Color
strongishGray theme =
    case theme of
        Light ->
            darkishGray

        Dark ->
            lightishGray


strongGray : Theme -> Element.Color
strongGray theme =
    case theme of
        Light ->
            darkGray

        Dark ->
            lightGray


strongerGray : Theme -> Element.Color
strongerGray theme =
    case theme of
        Light ->
            darkerGray

        Dark ->
            lighterGray


backgroundColor : Theme -> Element.Color
backgroundColor theme =
    case theme of
        Light ->
            white

        Dark ->
            black


fontColor : Theme -> Element.Color
fontColor theme =
    case theme of
        Light ->
            black

        Dark ->
            white


transparent : Element.Color
transparent =
    Element.rgba 0 0 0 0


css : String -> String -> Element.Attribute msg
css prop value =
    Element.htmlAttribute <|
        Html.Attributes.style prop value


each : { left : Int, right : Int, top : Int, bottom : Int }
each =
    { left = 0, right = 0, top = 0, bottom = 0 }


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



-- Icons taken from Mono icons


leftChevronIcon : Element.Color -> Element msg
leftChevronIcon color =
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
                , Svg.Attributes.fill <| toHex color
                ]
                []
            ]


rightChevronIcon : Element.Color -> Element msg
rightChevronIcon color =
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
                , Svg.Attributes.fill <| toHex color
                ]
                []
            ]


moonIcon : Element.Color -> Element msg
moonIcon color =
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
                , Svg.Attributes.fill <| toHex color
                ]
                []
            ]


sunIcon : Element.Color -> Element msg
sunIcon color =
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
                , Svg.Attributes.fill <| toHex color
                ]
                []
            ]


changeThemeIcon : Theme -> Element msg
changeThemeIcon theme =
    case theme of
        Light ->
            moonIcon darkGray

        Dark ->
            sunIcon lightGray


gridIcon : View -> Theme -> Element msg
gridIcon view_ theme =
    let
        color =
            case view_ of
                Chapter _ ->
                    strongGray theme

                Grid _ ->
                    strongerGray theme
    in
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
                , Svg.Attributes.fill <| toHex color
                ]
                []
            ]


buttonAttrs : List (Element.Attribute msg)
buttonAttrs =
    [ Border.width 1
    , Border.color transparent
    , Element.padding 8
    , Border.rounded 2
    , css "transition" "background 0.2s ease-out, border 0.2s ease-out, color 0.2s ease-out"
    ]


button :
    Theme
    -> List (Element.Attribute msg)
    -> { onPress : Maybe msg, label : Element msg }
    -> Element msg
button theme attrs =
    Input.button
        (attrs
            ++ buttonAttrs
            ++ [ Element.mouseOver
                    [ Background.color (subtlerGray theme)
                    ]
               , Element.mouseDown
                    [ Background.color (subtleGray theme)
                    ]
               , Background.color (backgroundColor theme)
               ]
        )


selectedButton :
    Theme
    -> List (Element.Attribute msg)
    -> { onPress : Maybe msg, label : Element msg }
    -> Element msg
selectedButton theme attrs =
    Input.button
        (attrs
            ++ buttonAttrs
            ++ [ Element.mouseOver
                    [ Background.color (subtleishGray theme)
                    ]
               , Element.mouseDown
                    [ Background.color (subtleishGray theme)
                    ]
               , Background.color (subtleGray theme)
               ]
        )


selectableButton :
    Bool
    -> Theme
    -> List (Element.Attribute msg)
    -> { onPress : Maybe msg, label : Element msg }
    -> Element msg
selectableButton selected =
    if selected then
        selectedButton

    else
        button


view : Model -> Document Msg
view model =
    { title = "Tao Te Ching"
    , body =
        [ Html.node
            "style"
            []
            [ Html.text
                ("""body {
                        background-color: {backgroundColor};
                        color: {fontColor};
                        width: 100%;
                        overflow-x: hidden;
                    }"""
                    |> String.replace "{backgroundColor}" (toHex <| backgroundColor model.theme)
                    |> String.replace "{fontColor}" (toHex <| fontColor model.theme)
                )
            ]
        , Element.layoutWith
            { options =
                [ Element.focusStyle
                    { borderColor =
                        Just (subtleGray model.theme)
                    , backgroundColor = Nothing
                    , shadow = Nothing
                    }
                ]
            }
            [ Font.size 20
            , Font.family [ Font.serif ]
            , css "transition" "0.2s ease-out"
            , Background.color (backgroundColor model.theme)
            , Font.color (fontColor model.theme)
            , Element.width Element.fill
            , Element.clipX
            ]
            (viewBody model)
        ]
    }


descriptionAndTitle : { english : String, spanish : String } -> List (Element.Attribute msg)
descriptionAndTitle { english, spanish } =
    let
        string =
            case language of
                English _ ->
                    english

                Spanish ->
                    spanish
    in
    [ Region.description string
    , Element.htmlAttribute <|
        Html.Attributes.title string
    ]


viewBody : Model -> Element Msg
viewBody model =
    Element.column
        [ Element.width <| Element.maximum 500 Element.fill
        , Element.centerX
        ]
        [ Element.row
            [ Element.alignRight
            , css "position" "sticky"
            , css "top" "0"
            , css "z-index" "99"
            , Region.navigation
            , Element.spacing 5
            ]
            [ button
                model.theme
                (descriptionAndTitle { english = "Previous chapter", spanish = "Capítulo anterior" })
                { onPress = Just (Pressed PreviousChapter)
                , label =
                    leftChevronIcon (strongGray model.theme)
                }
            , button
                model.theme
                (descriptionAndTitle { english = "Next chapter", spanish = "Siguiente capítulo" })
                { onPress = Just (Pressed NextChapter)
                , label =
                    rightChevronIcon (strongGray model.theme)
                }
            , selectableButton
                (isGridView model.view)
                model.theme
                (descriptionAndTitle { english = "Select chapter", spanish = "Elegir capítulo" })
                { onPress = Just (Pressed SelectChapter)
                , label =
                    gridIcon model.view model.theme
                }
            , button
                model.theme
                (descriptionAndTitle { english = "Toggle light/dark mode", spanish = "Alternar modo oscuro/claro" })
                { onPress = Just (Pressed ToggleTheme)
                , label =
                    changeThemeIcon model.theme
                }
            ]
        , viewMain model.theme model.view model.transition
        , viewFooter model.theme
        ]


viewMain : Theme -> View -> Transition -> Element Msg
viewMain theme currentView transition =
    case transition of
        FadeOut previousView ->
            viewView theme
                previousView
                [ css "transition" "0.2s ease-out"
                , css "transform" "scale(1)"
                , Element.alpha 0
                ]

        AboutToFadeIn ->
            viewView theme
                currentView
                [ css "transition" "0.0s ease-in"
                , css "transform" "scale(0.97)"
                , Element.alpha 0
                ]

        FadeIn ->
            viewView theme
                currentView
                [ css "transition" "opacity 0.2s ease-in, transform 0.2s ease-out"
                , css "transform" "scale(1)"
                , Element.alpha 1
                ]


{-| View wasn't a smart name xD
-}
viewView : Theme -> View -> List (Element.Attribute Msg) -> Element Msg
viewView theme currentView attrs =
    case currentView of
        Chapter currentChapter ->
            viewChapter currentChapter attrs

        Grid currentChapter ->
            viewGrid theme currentChapter attrs


viewGrid : Theme -> Int -> List (Element.Attribute Msg) -> Element Msg
viewGrid theme currentChapter attrs =
    Element.wrappedRow
        (Element.padding 20
            :: Element.spacing 10
            :: Element.width Element.fill
            :: attrs
        )
        (List.range 0 (Array.length chapters - 1)
            |> List.map (viewGridButton theme currentChapter)
        )


viewGridButton : Theme -> Int -> Int -> Element Msg
viewGridButton theme currentChapter chapterNumber =
    selectableButton
        (currentChapter == chapterNumber)
        theme
        [ Element.width <| Element.px 40
        , Element.height <| Element.px 40
        ]
        { onPress = Just (Pressed (ChapterNumber chapterNumber))
        , label =
            Element.el
                [ Element.centerX
                , Element.centerY
                ]
            <|
                Element.text <|
                    String.fromInt (chapterNumber + 1)
        }


viewChapter : Int -> List (Element.Attribute msg) -> Element msg
viewChapter chapterNumber attrs =
    case Array.get chapterNumber chapters of
        Just chapter ->
            Element.el
                (Element.width Element.fill
                    :: attrs
                )
                (viewChapterContent chapterNumber chapter)

        Nothing ->
            Element.el
                (Element.width Element.fill
                    :: Font.italic
                    :: attrs
                )
                (case language of
                    English _ ->
                        Element.text "No chapter selected"

                    Spanish ->
                        Element.text "No existe el capítulo seleccionado"
                )


viewChapterContent : Int -> String -> Element msg
viewChapterContent number chapter =
    Element.column
        [ Element.padding 10
        , Element.spacing 20
        , Element.width Element.fill
        ]
        [ Element.el
            [ Font.bold ]
            (Element.text <| String.fromInt <| number + 1)
        , Element.textColumn
            [ Element.spacing 5
            , Element.width Element.fill
            ]
            (chapterToParagraphs chapter)
        ]


chapterToParagraphs : String -> List (Element msg)
chapterToParagraphs chapter =
    chapter
        |> String.split "\n"
        |> List.map verseToParagraph


verseToParagraph : String -> Element msg
verseToParagraph verse =
    case String.trim verse of
        "" ->
            Element.html <|
                Html.br [] []

        _ ->
            Element.paragraph
                []
                [ Element.text verse
                ]


viewFooter : Theme -> Element msg
viewFooter theme =
    Element.textColumn
        [ Element.padding 10
        , Font.color (subtleishGray theme)
        , css "transition" "0.2s ease-out"
        , Font.size 15
        ]
        [ Element.paragraph
            []
            [ Element.text "Lao-Tzu, "
            , Element.el [ Font.italic ] <| Element.text "Tao Te Ching"
            ]
        , Element.paragraph
            []
            [ case language of
                English _ ->
                    Element.text "Translation by S. Mitchell"

                Spanish ->
                    Element.text "Traducción de S. Mitchell"
            ]
        ]
