module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Animation exposing (px, turn, percent)
import Color exposing (rgb, rgba)
import Animation.Pack


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.Pack.subscription Animate model.style


(=>) =
    (,)


init : ( Model, Cmd Msg )
init =
    let
        initialWidgetStyle =
            [ Animation.display Animation.inlineBlock
            , Animation.width (px 100)
            , Animation.height (px 100)
            , Animation.margin (px 50)
            , Animation.padding (px 25)
            , Animation.rotate (turn 0.0)
            , Animation.rotate3d (turn 0.0) (turn 0.0) (turn 0.0)
            , Animation.translate (px 0) (px 0)
            , Animation.opacity 1
            , Animation.backgroundColor Color.white
            , Animation.color Color.black
            , Animation.scale 1.0
            , Animation.borderColor Color.white
            , Animation.borderWidth (px 4)
            , Animation.borderRadius (px 8)
            , Animation.translate3d (percent 0) (percent 0) (px 0)
            , Animation.shadow
                { offsetX = 0
                , offsetY = 1
                , size = 0
                , blur = 2
                , color = rgba 0 0 0 0.1
                }
            ]

        widgets =
            [ { label = "Rotate"
              , action = RotateWidget
              , style = WidgetStyle 0
              }
            , { label = "Rotate in All Kinds of Ways"
              , action = RotateAllAxis
              , style = WidgetStyle 1
              }
            , { label = "Change Colors"
              , action = ChangeColors
              , style = WidgetStyle 2
              }
            , { label = "Change Through Multiple Colors"
              , action = ChangeMultipleColors
              , style = WidgetStyle 3
              }
            , { label = "Fade Out Fade In"
              , action = FadeOutFadeIn
              , style = WidgetStyle 4
              }
            , { label = "Take off!"
              , action = Shadow
              , style = WidgetStyle 5
              }
            ]
    in
        ( { widgets = widgets
          , style =
                widgets
                    |> List.indexedMap (\i _ -> ( WidgetStyle i, initialWidgetStyle ))
                    |> Animation.Pack.init
          }
        , Cmd.none
        )


type alias Model =
    { widgets : List Widget
    , style : Animation.Pack.Pack Style Msg
    }


type Style
    = WidgetStyle Int


type alias Widget =
    { label : String
    , action : MyAnimations
    , style : Style
    }


type Msg
    = RunAnimation MyAnimations Style
    | Animate Animation.Msg


type MyAnimations
    = RotateWidget
    | RotateAllAxis
    | ChangeColors
    | ChangeMultipleColors
    | FadeOutFadeIn
    | Shadow


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Animate animMsg ->
            let
                ( newStyle, cmds ) =
                    Animation.Pack.update animMsg model.style
            in
                ( { model
                    | style = newStyle
                  }
                , cmds
                )

        RunAnimation anim style ->
            case anim of
                RotateWidget ->
                    ( { model
                        | style =
                            model.style
                                |> Animation.Pack.animate style
                                    [ Animation.to
                                        [ Animation.rotate (turn 1) ]
                                    , Animation.set
                                        [ Animation.rotate (turn 0) ]
                                    ]
                      }
                    , Cmd.none
                    )

                RotateAllAxis ->
                    ( { model
                        | style =
                            model.style
                                |> Animation.Pack.animate style
                                    [ Animation.to
                                        [ Animation.rotate3d (turn 1) (turn 1) (turn 1)
                                        ]
                                    , Animation.set
                                        [ Animation.rotate3d (turn 0) (turn 0) (turn 0)
                                        ]
                                    ]
                      }
                    , Cmd.none
                    )

                ChangeColors ->
                    ( { model
                        | style =
                            model.style
                                |> Animation.Pack.animate style
                                    [ Animation.to
                                        [ Animation.backgroundColor (rgba 100 100 100 1.0)
                                        , Animation.borderColor (rgba 100 100 100 1.0)
                                        ]
                                    , Animation.to
                                        [ Animation.backgroundColor Color.white
                                        , Animation.borderColor Color.white
                                        ]
                                    ]
                      }
                    , Cmd.none
                    )

                ChangeMultipleColors ->
                    let
                        colorAnimation =
                            List.map
                                (\color ->
                                    Animation.to
                                        [ Animation.backgroundColor color
                                        , Animation.borderColor color
                                        ]
                                )
                                [ Color.red
                                , Color.orange
                                , Color.yellow
                                , Color.green
                                , Color.blue
                                , Color.purple
                                , Color.white
                                ]
                    in
                        ( { model
                            | style =
                                model.style
                                    |> Animation.Pack.animate style colorAnimation
                          }
                        , Cmd.none
                        )

                FadeOutFadeIn ->
                    ( { model
                        | style =
                            model.style
                                |> Animation.Pack.animate style
                                    [ Animation.to
                                        [ Animation.opacity 0
                                        ]
                                    , Animation.to
                                        [ Animation.opacity 1
                                        ]
                                    ]
                      }
                    , Cmd.none
                    )

                Shadow ->
                    ( { model
                        | style =
                            model.style
                                |> Animation.Pack.animate style
                                    [ Animation.to
                                        [ Animation.translate (px 100) (px 100)
                                        , Animation.scale 1.2
                                        , Animation.shadow
                                            { offsetX = 50
                                            , offsetY = 55
                                            , blur = 15
                                            , size = 0
                                            , color = rgba 0 0 0 0.1
                                            }
                                        ]
                                    , Animation.to
                                        [ Animation.translate (px 0) (px 0)
                                        , Animation.scale 1
                                        , Animation.shadow
                                            { offsetX = 0
                                            , offsetY = 1
                                            , size = 0
                                            , blur = 2
                                            , color = rgba 0 0 0 0.1
                                            }
                                        ]
                                    ]
                      }
                    , Cmd.none
                    )


view : Model -> Html Msg
view model =
    div
        [ Html.Attributes.style
            [ ( "position", "absolute" )
            , ( "left", "0px" )
            , ( "top", "0px" )
            , ( "width", "100%" )
            , ( "height", "100%" )
            , ( "background-color", "#f0f0f0" )
            ]
        ]
        [ div
            [ Html.Attributes.style
                [ ( "display", "flex" )
                , ( "flex-direction", "row" )
                , ( "flex-wrap", "wrap" )
                , ( "justify-content", "center" )
                , ( "position", "absolute" )
                , ( "left", "0px" )
                , ( "top", "0px" )
                , ( "width", "100%" )
                ]
            ]
            (List.map (viewWidget model.style) model.widgets)
        ]


viewWidget : Animation.Pack.Pack Style Msg -> Widget -> Html Msg
viewWidget style widget =
    div
        (Animation.Pack.render style widget.style
            ++ [ Html.Attributes.style
                    [ ( "position", "relative" )
                    , ( "text-align", "center" )
                    , ( "cursor", "pointer" )
                    , ( "border-style", "solid" )
                    , ( "vertical-align", "middle" )
                    ]
               , onMouseOver (RunAnimation widget.action widget.style)
               ]
        )
        [ text widget.label ]
