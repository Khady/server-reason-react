let test title fn = Alcotest.test_case title `Quick fn

let assert_string left right =
  Alcotest.check Alcotest.string "should be equal" right left

let set_router () =
  ReasonReactRouter.Router.URL.set
    { path = [ "question" ]; hash = "dontpanic"; search = "answer=42" };
  let url =
    match ReasonReactRouter.Router.URL.get () with
    | Some url -> url
    | None -> raise (Failure "Native URL not set")
  in
  assert_string
    ((url.path |> String.concat "/") ^ "; " ^ url.hash ^ "; " ^ url.search)

let use_url_works () =
  ReasonReactRouter.Router.URL.set
    { path = [ "question" ]; hash = "dontpanic"; search = "answer=42" };
  let app =
    React.Upper_case_component
      (fun () ->
        let url = ReasonReactRouter.useUrl () in
        React.createElement "div" []
          [
            React.string "Question: ";
            React.string (url.path |> String.concat "/");
            React.string "; Hash: ";
            React.string url.hash;
            React.string "; Search: ";
            React.string url.search;
          ])
  in
  assert_string
    (ReactDOM.renderToStaticMarkup app)
    "<div>Question: question; Hash: dontpanic; Search: answer=42</div>"

let use_url_fails () =
  let make_app () =
    React.Upper_case_component
      (fun () ->
        let url = ReasonReactRouter.useUrl () in
        React.createElement "div" []
          [
            React.string "Question: ";
            React.string (url.path |> String.concat "/");
            React.string "; Hash: ";
            React.string url.hash;
            React.string "; Search: ";
            React.string url.search;
          ])
  in
  try make_app () |> ReactDOM.renderToStaticMarkup |> ignore
  with Failure msg -> assert_string "Native URL not set" msg

let use_url_with_server_url_works () =
  let app =
    React.Upper_case_component
      (fun () ->
        let url =
          ReasonReactRouter.useUrl
            ~serverUrl:
              {
                path = [ "question" ];
                hash = "dontpanic";
                search = "answer=42";
              }
            ()
        in
        React.createElement "div" []
          [
            React.string "Question: ";
            React.string (url.path |> String.concat "/");
            React.string "; Hash: ";
            React.string url.hash;
            React.string "; Search: ";
            React.string url.search;
          ])
  in
  assert_string
    (ReactDOM.renderToStaticMarkup app)
    "<div>Question: question; Hash: dontpanic; Search: answer=42</div>"

let tests =
  ( "ReasonReactRouter",
    [
      test "useUrl" use_url_works;
      test "useUrl fails" use_url_fails;
      test "useUrl with serverUrl" use_url_with_server_url_works;
    ] )
