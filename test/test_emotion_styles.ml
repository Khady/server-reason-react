open Alcotest

let assert_string left right = (check string) "should be equal" right left

let test_one_property () =
  let style = Emotion.create () in
  let _className = style [ Css.Properties.display `block ] in
  let css = Emotion.render_style_tag () in
  assert_string css ".s362999430 { display: block; }"

let test_multiple_properties () =
  let style = Emotion.create () in
  let _className =
    style [ Css.Properties.display `block; Css.Properties.fontSize (`px 10) ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css ".s1016840165 { display: block; font-size: 10px; }"

let test_selector_one_nesting () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.color Css.Colors.aliceblue
      ; Css.Properties.selector "a"
          [ Css.Properties.color Css.Colors.rebeccapurple ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s1631319699 { color: #F0F8FF; } .s1631319699 a { color: #663399; }"

let test_selector_more_than_one_nesting () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.color Css.Colors.aliceblue
      ; Css.Properties.selector "a"
          [ Css.Properties.display `block
          ; Css.Properties.selector "div" [ Css.Properties.display `none ]
          ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s105107207 { color: #F0F8FF; } .s105107207 a { display: block; } \
     .s105107207 a div { display: none; }"

let test_selector_with_a_lot_of_nesting () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.display `flex
      ; Css.Properties.selector "a"
          [ Css.Properties.display `block
          ; Css.Properties.selector "div"
              [ Css.Properties.display `none
              ; Css.Properties.selector "span"
                  [ Css.Properties.display `none
                  ; Css.Properties.selector "hr"
                      [ Css.Properties.display `none
                      ; Css.Properties.selector "code"
                          [ Css.Properties.display `none ]
                      ]
                  ]
              ]
          ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s695613379 { display: flex; } .s695613379 a { display: block; } \
     .s695613379 a div { display: none; } .s695613379 a div span { display: \
     none; } .s695613379 a div span hr { display: none; } .s695613379 a div \
     span hr code { display: none; }"

let test_with_react () =
  let style = Emotion.create () in
  let className = style [ Css.Properties.display `block ] in
  let css = Emotion.render_style_tag () in
  let head =
    React.createElement "head" [||]
      [ React.createElement "style" [||] [ React.string css ] ]
  in
  let body =
    React.createElement "body" [||]
      [ React.createElement "div"
          [| React.Attribute.String ("className", className) |]
          []
      ]
  in
  let app = React.createElement "html" [||] [ head; body ] in
  assert_string
    (ReactDOM.renderToStaticMarkup app)
    "<html><head><style>.s362999430 { display: block; \
     }</style></head><body><div class=\"s362999430\"></div></body></html>"

let test_selector_ampersand () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.fontSize (`px 42)
      ; Css.Properties.selector "& .div" [ Css.Properties.fontSize (`px 24) ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s1978948461 { font-size: 42px; } .s1978948461 .div { font-size: 24px; }"

let test_selector_ampersand_at_the_middle () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.fontSize (`px 42)
      ; Css.Properties.selector "& div &" [ Css.Properties.fontSize (`px 24) ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s1368516918 { font-size: 42px; } .s1368516918 div .s1368516918 { \
     font-size: 24px; }"

let test_media_queries () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.maxWidth (`px 800)
      ; Css.Properties.media "(max-width: 768px)"
          [ Css.Properties.width (`px 300) ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s2073633259 { max-width: 800px; } @media (max-width: 768px) { \
     .s2073633259 { width: 300px; } }"

(* let test_media_queries_nested () =
   let style = Emotion.create () in
   let _className =
     style
       [ Css.Properties.maxWidth (`px 800)
       ; Css.Properties.media "(max-width: 768px)"
           [ Css.Properties.width (`px 300)
           ; Css.Properties.media "(min-width: 400px)"
               [ Css.Properties.width (`px 300) ]
           ]
       ]
   in
   let css = Emotion.render_style_tag () in
   assert_string css
     ".s2073633259 { max-width: 800px; } @media (max-width: 768px) { \
      .s2073633259 { width: 300px; } }"
*)
let test_selector_params () =
  let style = Emotion.create () in
  let _className =
    style
      [ Css.Properties.maxWidth (`px 800)
      ; Css.Properties.firstChild [ Css.Properties.width (`px 300) ]
      ]
  in
  let css = Emotion.render_style_tag () in
  assert_string css
    ".s1464869224 { max-width: 800px; } .s1464869224:first-child { width: \
     300px; }"

let test_keyframe () =
  let style = Emotion.create () in
  let loading = "random" in
  (* let loading =
       Emotion.keyframes
         [ (0, [ Css.Properties.transform (`rotate (`deg 0.)) ])
         ; (100, [ Css.Properties.transform (`rotate (`deg (-360.))) ])
         ]
     in *)
  let _className = style [ Css.Properties.animationName loading ] in
  let css = Emotion.render_style_tag () in
  assert_string css ".s532385609 { animation-name: random; }"

let tests =
  ( "Emotion"
  , [ test_case "test_with_react_component" `Quick test_with_react
    ; test_case "test_one_property" `Quick test_one_property
    ; test_case "test_multiple_properties" `Quick test_multiple_properties
    ; test_case "test_selector_one_nesting" `Quick test_selector_one_nesting
    ; test_case "test_selector_more_than_one_nesting" `Quick
        test_selector_more_than_one_nesting
    ; test_case "test_selector_with_a_lot_of_nesting" `Quick
        test_selector_with_a_lot_of_nesting
    ; test_case "test_media_queries" `Quick test_media_queries
      (* ; test_case "test_media_queries_nested" `Quick test_media_queries_nested *)
    ; test_case "test_selector_ampersand" `Quick test_selector_ampersand
    ; test_case "test_selector_params" `Quick test_selector_params
    ; test_case "test_keyframe" `Quick test_keyframe
    ] )
