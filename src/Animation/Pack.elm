module Animation.Pack exposing (Pack, init, animate, queue, subscription, update, render, add, remove)

{-|
Manage your animation states!

@docs Pack, init, animate, queue, subscription, update, render


# Dynamically adding or removing `Animation.State`s.

@docs add, remove



-}

import Dict exposing (Dict)
import Animation
import Animation.Messenger
import Html


{-| A collection of `Animation.State`s
-}
type Pack id msg
    = Pack (Maybe id) (Dict String (Animation.Messenger.State msg))


{-| -}
toName : a -> String
toName =
    toString


{-| -}
init : List ( id, List Animation.Property ) -> Pack id msg
init styles =
    styles
        |> List.map (\( id, style ) -> ( toName id, Animation.style style ))
        |> Dict.fromList
        |> Pack Nothing


{-| Add a new Animation.State to the pack.

You need one animation state per entity you want to animate.
-}
add : id -> List Animation.Property -> Pack id msg -> Pack id msg
add id style (Pack mId states) =
    Pack mId <| Dict.insert (toName id) (Animation.style style) states


{-| Remove an animation state if it's no longer needed for rendering.
-}
remove : id -> Pack id msg -> Pack id msg
remove id (Pack mId states) =
    Pack mId <| Dict.remove (toName id) states


{-| Start an animation using `Animation.interrupt`

In your update function, it will look something like this:

```
    StartAnimation ->
        let
            newStyles =
                model.styles
                    |> Animation.Pack.animate MyStyle
                        [ Animation.to
                            [ Animation.left (px 0.0)
                            , Animation.opacity 1.0
                            ]
                        ]

        in
            ( { model | styles = newStyles }
            , Cmd.none
            )
```

-}
animate : id -> List (Animation.Messenger.Step msg) -> Pack id msg -> Pack id msg
animate id steps (Pack mId states) =
    let
        name =
            toName id

        makeUpdate mState =
            case mState of
                Nothing ->
                    let
                        _ =
                            Debug.log
                                "elm-animation-pack"
                                (name ++ " could not be found but you're trying to animate it!")
                    in
                        Nothing

                Just state ->
                    Just <| Animation.interrupt steps state
    in
        Pack mId <| Dict.update name makeUpdate states


{-| Same as `animate` except use `Animation.queue` instead of `Animation.interrupt`.

-}
queue : id -> List (Animation.Messenger.Step msg) -> Pack id msg -> Pack id msg
queue id steps (Pack mId states) =
    let
        name =
            toName id

        makeUpdate mState =
            case mState of
                Nothing ->
                    let
                        _ =
                            Debug.log
                                "elm-animation-pack"
                                (name ++ " could not be found but you're trying to animate it!")
                    in
                        Nothing

                Just state ->
                    Just <| Animation.queue steps state
    in
        Pack mId <| Dict.update name makeUpdate states


{-| You need to add a subscription to your `Animation.Pack` in order for animations to work.

It generally looks something like this:

```
    , subscriptions = (\model -> Animation.Pack.subscription Animate model.styles)
```


-}
subscription : (Animation.Msg -> msg) -> Pack id msg -> Sub msg
subscription message (Pack _ states) =
    Animation.subscription message (Dict.values states)


{-|

-}
update : Animation.Msg -> Pack id msg -> ( Pack id msg, Cmd msg )
update animMsg (Pack mId states) =
    let
        ( newPack, cmds ) =
            Dict.foldl
                (\name state ( existing, cmd ) ->
                    let
                        ( newState, newCmds ) =
                            Animation.Messenger.update animMsg state
                    in
                        ( Dict.insert name newState existing
                        , Cmd.batch [ cmd, newCmds ]
                        )
                )
                ( states, Cmd.none )
                states
    in
        ( Pack mId newPack, cmds )


{-| -}
render : Pack id msg -> id -> List (Html.Attribute msg)
render (Pack _ states) id =
    case Dict.get (toName id) states of
        Nothing ->
            []

        Just anim ->
            Animation.render anim
