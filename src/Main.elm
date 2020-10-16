port module Main exposing (main)

import AddissAndLombardo.TaoTeChing
import Array exposing (Array)
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Navigation
import Cmd.Extra
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Lazy
import Element.Region as Region
import Html
import Html.Attributes
import Html.Lazy
import Icons
import Json.Decode
import Maybe.Extra
import Point exposing (Point)
import Spanish.TaoTeChing
import Svg
import Svg.Attributes
import TaoTeChing
import Task
import Time
import Url exposing (Url)
import Utils



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
    English StephenMitchell


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
        , onUrlRequest = ReceivedUrlRequest
        , onUrlChange = UrlChanged
        }



--- MODEL


type alias Model =
    { page : Page
    , navigationKey : Navigation.Key
    , theme : Theme
    , transition : Transition
    , touch : Touch
    }


type Transition
    = FadingOut Page
    | AboutToFadeIn
    | FadeIn


init : Json.Decode.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        chapterFromUrl =
            getChapterFromUrl url

        chapterFromFlags =
            getChapterFromFlags flags
    in
    ( { page =
            Maybe.Extra.or chapterFromUrl chapterFromFlags
                |> Maybe.withDefault 0
                |> Chapter
      , navigationKey =
            navKey
      , theme =
            getThemeFromFlags flags
      , transition =
            AboutToFadeIn
      , touch = NotTouching
      }
    , case ( chapterFromUrl, chapterFromFlags ) of
        ( Nothing, Just chapter ) ->
            Navigation.replaceUrl navKey (chapterNumberToUrl chapter)

        _ ->
            Cmd.none
    )


loadUrl : Url -> Model -> Model
loadUrl url model =
    model
        |> withPage (getChapterFromUrl url |> Maybe.withDefault 0 |> Chapter)


withPage : Page -> Model -> Model
withPage page model =
    { model | page = page }


withTransition : Transition -> Model -> Model
withTransition transition model =
    { model | transition = transition }


withTheme : Theme -> Model -> Model
withTheme theme model =
    { model | theme = theme }


withTouch : Touch -> Model -> Model
withTouch touch model =
    { model | touch = touch }



-- CHAPTER NUMBERS


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


chapterNumberToUrl : Int -> String
chapterNumberToUrl chapterNumber =
    "#" ++ String.fromInt (chapterNumber + 1)


getChapterFromFlags : Json.Decode.Value -> Maybe Int
getChapterFromFlags value =
    value
        |> Json.Decode.decodeValue
            (Json.Decode.field "currentChapter" Json.Decode.int)
        |> Result.toMaybe



--- THEME


type Theme
    = Light
    | Dark


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



--- VIEW
-- This should be called "screen" or "page".
-- It represents the currently visible "page"
-- (everything except the header buttons and the footer).


type Page
    = Chapter Int
    | Grid Int


getCurrentChapter : Page -> Int
getCurrentChapter page =
    case page of
        Chapter currentChapter ->
            currentChapter

        Grid currentChapter ->
            currentChapter


isGridPage : Page -> Bool
isGridPage page =
    case page of
        Chapter _ ->
            False

        Grid _ ->
            True



--- TOUCH
-- When we're Touching, we save the timestamp to know
-- if we performed a swipe gesture fast enough.


type Touch
    = NotTouching
    | Touching Int Point
    | Dragging Int Point Point


moveToPoint : Point -> Touch -> Touch
moveToPoint point touch =
    case touch of
        NotTouching ->
            NotTouching

        Touching timestamp startPoint ->
            Dragging timestamp startPoint point

        Dragging timestamp startPoint _ ->
            Dragging timestamp startPoint point



--- UPDATE


type Msg
    = ReceivedUrlRequest UrlRequest
    | UrlChanged Url
    | Pressed Button
    | AnimationFramePassed Time.Posix
    | TransitionTimePassed Time.Posix
    | PressedKey String
    | TouchStarted Json.Decode.Value
    | TouchMoved Json.Decode.Value
    | TouchEnded {}
    | VisibilityChanged Browser.Events.Visibility
    | GotTimeAfterTouchStarted Point Time.Posix
    | GotTimeAfterTouchEnded Time.Posix


type Button
    = PreviousChapter
    | NextChapter
    | ChapterGrid
    | ToggleTheme
    | ChapterNumber Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedUrlRequest (Browser.Internal url) ->
            model
                |> Cmd.Extra.withCmd (Navigation.pushUrl model.navigationKey <| Url.toString url)

        ReceivedUrlRequest (Browser.External string) ->
            model
                |> Cmd.Extra.withCmd (Navigation.load string)

        UrlChanged url ->
            loadUrl url model
                |> Cmd.Extra.withNoCmd

        Pressed PreviousChapter ->
            model
                |> loadChapterView model.navigationKey (getCurrentChapter model.page - 1)

        Pressed NextChapter ->
            model
                |> loadChapterView model.navigationKey (getCurrentChapter model.page + 1)

        Pressed ChapterGrid ->
            toggleChapterSelection model

        Pressed ToggleTheme ->
            model
                |> withTheme (toggleTheme model.theme)
                |> Cmd.Extra.withCmd (saveInLocalStorage ( "theme", toggleTheme model.theme |> themeToString ))

        Pressed (ChapterNumber chapterNumber) ->
            model
                |> loadChapterView model.navigationKey chapterNumber

        TransitionTimePassed _ ->
            model
                |> withTransition AboutToFadeIn
                |> Cmd.Extra.withNoCmd

        AnimationFramePassed _ ->
            model
                |> withTransition FadeIn
                |> Cmd.Extra.withNoCmd

        PressedKey "ArrowLeft" ->
            model
                |> loadChapterView model.navigationKey (getCurrentChapter model.page - 1)

        PressedKey "ArrowRight" ->
            model
                |> loadChapterView model.navigationKey (getCurrentChapter model.page + 1)

        PressedKey _ ->
            model
                |> Cmd.Extra.withNoCmd

        TouchStarted value ->
            case Json.Decode.decodeValue Point.decoder value of
                Ok point ->
                    model
                        |> Cmd.Extra.withCmd
                            (Time.now |> Task.perform (GotTimeAfterTouchStarted point))

                Err _ ->
                    model
                        |> Cmd.Extra.withNoCmd

        GotTimeAfterTouchStarted point posix ->
            model
                |> withTouch (Touching (Time.posixToMillis posix) point)
                |> Cmd.Extra.withNoCmd

        TouchMoved value ->
            case Json.Decode.decodeValue Point.decoder value of
                Ok point ->
                    model
                        |> withTouch (moveToPoint point model.touch)
                        |> Cmd.Extra.withNoCmd

                Err _ ->
                    model |> Cmd.Extra.withNoCmd

        TouchEnded {} ->
            model
                |> Cmd.Extra.withCmd
                    (Time.now |> Task.perform GotTimeAfterTouchEnded)

        GotTimeAfterTouchEnded posix ->
            endTouch (Time.posixToMillis posix) model

        VisibilityChanged Browser.Events.Hidden ->
            model
                |> withTouch NotTouching
                |> Cmd.Extra.withNoCmd

        VisibilityChanged _ ->
            model
                |> Cmd.Extra.withNoCmd


toggleChapterSelection : Model -> ( Model, Cmd Msg )
toggleChapterSelection model =
    let
        nextPage =
            case model.page of
                Chapter currentChapter ->
                    Grid currentChapter

                Grid currentChapter ->
                    Chapter currentChapter
    in
    changeView nextPage model


changeView : Page -> Model -> ( Model, Cmd Msg )
changeView nextPage model =
    model
        |> withPage nextPage
        |> withTransition (FadingOut model.page)
        |> Cmd.Extra.withCmd
            (saveInLocalStorage
                ( "currentChapter", getCurrentChapter nextPage |> String.fromInt )
            )


loadChapterView : Navigation.Key -> Int -> Model -> ( Model, Cmd Msg )
loadChapterView navigationKey chapterNumber model =
    let
        nextChapter =
            clamp 0 (Array.length chapters - 1) chapterNumber

        nextPage =
            Chapter nextChapter
    in
    if model.page /= nextPage then
        changeView nextPage model
            |> Cmd.Extra.addCmd
                (Navigation.pushUrl navigationKey
                    (chapterNumberToUrl nextChapter)
                )

    else
        model
            |> Cmd.Extra.withNoCmd


endTouch : Int -> Model -> ( Model, Cmd Msg )
endTouch endTime model =
    case model.touch of
        NotTouching ->
            model |> Cmd.Extra.withNoCmd

        Touching startTime startPoint ->
            model
                |> withTouch NotTouching
                |> Cmd.Extra.withNoCmd

        Dragging startTime startPoint endPoint ->
            let
                timeDiff =
                    endTime - startTime

                xDiff =
                    Point.x endPoint - Point.x startPoint

                yDiff =
                    Point.y endPoint - Point.y startPoint

                -- A line with equation y = m*x has slope=m.
                -- In this case we want a small slope to be sure
                -- the swipe gesture is horizontal and not vertical.
                slope =
                    toFloat (abs yDiff) / toFloat (abs xDiff)
            in
            if timeDiff < 500 && slope < 0.5 then
                if xDiff > 15 then
                    loadChapterView model.navigationKey
                        (getCurrentChapter model.page - 1)
                        model

                else if xDiff < -15 then
                    loadChapterView model.navigationKey
                        (getCurrentChapter model.page + 1)
                        model

                else
                    model |> Cmd.Extra.withNoCmd

            else
                model |> Cmd.Extra.withNoCmd


port saveInLocalStorage : ( String, String ) -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model.transition of
            FadingOut _ ->
                -- The transition duration is hard-coded everywhere to be 0.2s.
                -- I'm pretty confident I'm not going to change it so it's okay
                -- that it's hard-coded.
                Time.every 200 TransitionTimePassed

            AboutToFadeIn ->
                Browser.Events.onAnimationFrame AnimationFramePassed

            _ ->
                Sub.none
        , Browser.Events.onKeyDown keyDownDecoder
        , Browser.Events.onVisibilityChange VisibilityChanged
        , onTouchStart TouchStarted
        , onTouchMove TouchMoved
        , onTouchEnd TouchEnded
        ]


keyDownDecoder : Json.Decode.Decoder Msg
keyDownDecoder =
    Json.Decode.field "key" Json.Decode.string
        |> Json.Decode.map PressedKey


port onTouchStart : (Json.Decode.Value -> msg) -> Sub msg


port onTouchMove : (Json.Decode.Value -> msg) -> Sub msg


port onTouchEnd : ({} -> msg) -> Sub msg



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


changeThemeIcon : Theme -> Element msg
changeThemeIcon theme =
    case theme of
        Light ->
            Icons.moon darkGray

        Dark ->
            Icons.sun lightGray


gridIcon : Page -> Theme -> Element msg
gridIcon page theme =
    let
        color =
            case page of
                Chapter _ ->
                    strongGray theme

                Grid _ ->
                    strongerGray theme
    in
    Icons.grid color


buttonAttrs : List (Element.Attribute msg)
buttonAttrs =
    [ Border.width 1
    , Border.color transparent
    , Element.padding 8
    , Border.rounded 2
    , css "transition" "background 0.2s ease-out, border 0.2s ease-out, color 0.2s ease-out"
    ]



--- BUTTONS
-- Current implementation works best with 24-px mono icons, because padding
-- is hard-coded to give a total width/height of 40px when used with icons.
-- (I use mostly 5*2^n measures: 5px, 10px, 20px, 40px, 80px...)


disabledButton :
    Theme
    -> List (Element.Attribute msg)
    -> Element msg
    -> Element msg
disabledButton theme attrs =
    Element.el
        (attrs
            ++ buttonAttrs
            ++ [ Background.color (backgroundColor theme)
               ]
        )


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
        [ Html.Lazy.lazy bodyStyles model.theme
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
            (Element.Lazy.lazy3 viewBody model.theme model.page model.transition)
        ]
    }


bodyStyles : Theme -> Html.Html msg
bodyStyles theme =
    Html.node
        "style"
        []
        [ Html.text
            ("""body {
                        background-color: {backgroundColor};
                        color: {fontColor};
                        width: 100%;
                        overflow-x: hidden;
                    }"""
                |> String.replace "{backgroundColor}" (Utils.toHex <| backgroundColor theme)
                |> String.replace "{fontColor}" (Utils.toHex <| fontColor theme)
            )
        ]


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


buttonRow : List (Element.Attribute msg) -> List (Element msg) -> Element msg
buttonRow attrs children =
    Element.row
        (attrs
            ++ [ Element.alignRight
               , Element.spacing 5
               , Element.paddingXY 10 5
               ]
        )
        children


viewBody : Theme -> Page -> Transition -> Element Msg
viewBody theme page transition =
    Element.column
        [ Element.width <| Element.maximum 500 Element.fill
        , Element.centerX
        ]
        [ buttonRow
            [ Region.navigation ]
            [ selectableButton
                (isGridPage page)
                theme
                (descriptionAndTitle { english = "Select chapter", spanish = "Elegir capítulo" })
                { onPress = Just (Pressed ChapterGrid)
                , label =
                    gridIcon page theme
                }
            , button
                theme
                (descriptionAndTitle { english = "Toggle light/dark mode", spanish = "Alternar modo oscuro/claro" })
                { onPress = Just (Pressed ToggleTheme)
                , label =
                    changeThemeIcon theme
                }
            ]
        , viewMain theme page transition
        , viewFooter theme
        ]


viewMain : Theme -> Page -> Transition -> Element Msg
viewMain theme currentView transition =
    case transition of
        FadingOut previousView ->
            viewPage theme
                previousView
                [ css "transition" "0.2s ease-out"
                , css "transform" "scale(1)"
                , Element.alpha 0
                ]

        AboutToFadeIn ->
            viewPage theme
                currentView
                [ css "transition" "0.0s ease-in"
                , css "transform" "scale(0.97)"
                , Element.alpha 0
                ]

        FadeIn ->
            viewPage theme
                currentView
                [ css "transition" "opacity 0.2s ease-in, transform 0.2s ease-out"
                , css "transform" "scale(1)"
                , Element.alpha 1
                ]


viewPage : Theme -> Page -> List (Element.Attribute Msg) -> Element Msg
viewPage theme page attrs =
    case page of
        Chapter currentChapter ->
            viewChapter theme currentChapter attrs

        Grid currentChapter ->
            viewGrid theme currentChapter attrs


viewNavigationButtons : Theme -> Int -> Element Msg
viewNavigationButtons theme currentChapter =
    buttonRow
        [ Region.navigation ]
        [ if currentChapter > 0 then
            button
                theme
                (descriptionAndTitle { english = "Previous chapter", spanish = "Capítulo anterior" })
                { onPress = Just (Pressed PreviousChapter)
                , label =
                    Icons.leftChevron (strongGray theme)
                }

          else
            disabledButton
                theme
                (descriptionAndTitle { english = "Previous chapter (disabled button)", spanish = "Capítulo anterior (botón inactivo)" })
                (Icons.leftChevron <| subtleGray theme)
        , if currentChapter < Array.length chapters - 1 then
            button
                theme
                (descriptionAndTitle { english = "Next chapter", spanish = "Siguiente capítulo" })
                { onPress = Just (Pressed NextChapter)
                , label =
                    Icons.rightChevron (strongGray theme)
                }

          else
            disabledButton
                theme
                (descriptionAndTitle { english = "Next chapter (disabled button)", spanish = "Siguiente capítulo (botón inactivo)" })
                (Icons.rightChevron <| subtleGray theme)
        ]


viewGrid : Theme -> Int -> List (Element.Attribute Msg) -> Element Msg
viewGrid theme currentChapter attrs =
    Element.column
        (Element.width Element.fill
            :: attrs
        )
        [ Element.wrappedRow
            [ Element.padding 20
            , Element.spacing 10
            , Element.width Element.fill
            , Font.family [ Font.sansSerif ]
            , Font.size 16
            ]
            (List.range 0 (Array.length chapters - 1)
                |> List.map (viewGridButton theme currentChapter)
            )
        , viewNavigationButtons theme currentChapter
        ]


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


viewChapter : Theme -> Int -> List (Element.Attribute Msg) -> Element Msg
viewChapter theme chapterNumber attrs =
    case Array.get chapterNumber chapters of
        Just chapter ->
            Element.column
                (Element.width Element.fill
                    :: attrs
                )
                (viewChapterContent chapterNumber chapter
                    :: [ viewNavigationButtons theme chapterNumber ]
                )

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
                English StephenMitchell ->
                    Element.text "Translation by S. Mitchell"

                English AddissAndLombardo ->
                    Element.text "Translation by Addiss & Lombardo"

                Spanish ->
                    Element.text "Traducción de S. Mitchell"
            ]
        ]
