module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Animation exposing (px)
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
    ( { style =
            Animation.Pack.init
                [ Menu
                    => [ Animation.left (px -200.0)
                       , Animation.opacity 0
                       ]
                ]
      }
    , Cmd.none
    )


type alias Model =
    { style : Animation.Pack.Pack Styles Msg }


type Styles
    = Menu


type Msg
    = Show
    | Hide
    | Animate Animation.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Show ->
            ( { model
                | style =
                    Animation.Pack.animate Menu
                        [ Animation.to
                            [ Animation.left (px 0.0)
                            , Animation.opacity 1.0
                            ]
                        ]
                        model.style
              }
            , Cmd.none
            )

        Hide ->
            ( { model
                | style =
                    Animation.Pack.animate Menu
                        [ Animation.to
                            [ Animation.left (px -200.0)
                            , Animation.opacity 0
                            ]
                        ]
                        model.style
              }
            , Cmd.none
            )

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


view : Model -> Html Msg
view model =
    div
        [ onMouseEnter Show
        , onMouseLeave Hide
        , style
            [ ( "position", "absolute" )
            , ( "left", "0px" )
            , ( "top", "0px" )
            , ( "width", "350px" )
            , ( "height", "100%" )
            , ( "border", "2px dashed #AAA" )
            ]
        ]
        [ h1 [ style [ ( "padding", "25px" ) ] ]
            [ text "Hover here to see menu!" ]
        , div
            (Animation.Pack.render model.style Menu
                ++ [ style
                        [ ( "position", "absolute" )
                        , ( "top", "-2px" )
                        , ( "margin-left", "-2px" )
                        , ( "padding", "25px" )
                        , ( "width", "300px" )
                        , ( "height", "100%" )
                        , ( "background-color", "rgb(58,40,69)" )
                        , ( "color", "white" )
                        , ( "border", "2px solid rgb(58,40,69)" )
                        ]
                   ]
            )
            [ h1 [] [ text "Hidden Menu" ]
            , ul []
                [ li [] [ text "Some things" ]
                , li [] [ text "in a list" ]
                ]
            ]
        ]
