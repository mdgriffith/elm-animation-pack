# Manage your Elm animation states!

Managing your animation states in Elm can be a pain.  This module is an attempt at making it a little bit easier.

Essentially this module uses a dict behind the scenes to keep track of your animation states.  This comes with some tradeoffs, check the __warnings__ section at the bottom of the doc.


## Code Example

Initial model and subscription.
```
import Color
import Animation
import Animation.Pack

type MyStyles 
    = MyStyle 
    | OtherStyle

-- Fancy alias for the tuple comma
(=>) = (,)

-- Your initial model.
init =
    { styles = 
        Animation.Pack.init
            [ MyStyle =>
                [ Animation.opacity 0.0
                , Animation.color Color.blue
                , Animation.left (px 0.0)
                ]
            , OtherStyle =>
                [ Animation.opacity 0.0
                , Animation.color Color.blue
                , Animation.left (px 0.0)
                ]
            ]
    }

-- ..
   , subscriptions = (\model -> Animation.Pack.subscription Animate model.styles)

```


#### Starting multiple animations in your update function
```elm
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
                    |> Animation.Pack.animate OtherStyle
                        [ Animation.to
                            [ Animation.color Color.red
                            , Animation.top (px 80)
                            ]
                        ]
                }
        in
            ( { model | styles = newStyles }
            , Cmd.none
            )
```

#### Updating Animation
```elm
    Animate animMsg ->
        ( { model | styles = Animation.Pack.update animMsg model.styles }
        , Cmd.none
        )


```



## Warnings

Because this module is using a dict behind the scenes, you lose some of the strengths of elm's type checking.

Here are all the pitfalls you need to be aware of:

  * If you try to animate a state that doesn't exist, you'll get a logged warning (i.e. runtime notification)
  * If you try to 
  * Be wary about spawning new animation states willy nilly.  In other words, be careful about using `Animation.Pack.add` all the time.







