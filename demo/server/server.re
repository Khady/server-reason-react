/**

  This is a demo of a HTTP server that demostrates the possibility of Html_of_jsx.

  It uses `tiny_httpd` to keep the dependencies to a minimum. It also contains a bunch of utilities to generate styles.

*/
module Httpd = Tiny_httpd;
module Httpd_dir = Tiny_httpd_dir;

let globalStyles = {js|
  html, body, #root {
    margin: 0;
    padding: 0;
    width: 100vw;
    height: 100vh;
  }

  * {
    font-family: -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    box-sizing: border-box;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
|js};

module Page = {
  [@react.component]
  let make = (~children, ~scripts as _=[]) => {
    <html>
      <head>
        <meta charSet="UTF-8" />
        <meta
          name="viewport"
          content="width=device-width, initial-scale=1.0"
        />
        <title> {React.string("Server Reason React demo")} </title>
        <link
          rel="shortcut icon"
          href="https://reasonml.github.io/img/icon_50.png"
        />
        <style
          type_="text/css"
          dangerouslySetInnerHTML={"__html": globalStyles}
        />
        <script src="https://cdn.tailwindcss.com" />
      </head>
      <body> <div id="root"> children </div> </body>
    </html>;
  };
};

module Link = {
  [@react.component]
  let make = (~href, ~children) => {
    let (useState, setState) = React.useState(() => false);

    React.useEffect0(() => {
      setState(_prev => !useState);

      None;
    });

    <a
      onClick={_e => print_endline("clicked")}
      className="font-medium text-blue-600 hover:underline flex items-center"
      href>
      {React.string(children)}
      <svg
        className="w-3 h-3 ms-2 rtl:rotate-180"
        ariaHidden=true
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 14 10">
        <path
          stroke="currentColor"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          d="M1 5h12m0 0L9 1m4 4L9 9"
        />
      </svg>
    </a>;
  };
};

module Home = {
  [@react.component]
  let make = () => {
    <div className="p-8">
      <h1 className="font-bold text-2xl">
        {React.string("Home page of the demos")}
      </h1>
      <br />
      <ul>
        <li> <Link href="/markup"> "Markup" </Link> </li>
        <li> <Link href="/string"> "String" </Link> </li>
        <li> <Link href="/header"> "Header" </Link> </li>
      </ul>
    </div>;
  };
};

module Not_found = {
  [@react.component]
  let make = (~path) => {
    <div className="p-12">
      <Shared_native.Spacer bottom=4>
        <h1 className="font-bold text-5xl"> {React.string("Not found")} </h1>
      </Shared_native.Spacer>
      <span className="text-xl font-bold"> {React.string("Error 404")} </span>
      <span className="text-xl"> {React.string(" · ")} </span>
      <span className="text-xl"> {React.string("The requested URL")} </span>
      <span
        className="bg-slate-200 mx-2 py-1 px-3 no-underline rounded-full font-sans font-semibold">
        {React.string(path)}
      </span>
      <span className="text-xl">
        {React.string("was not found on this server.")}
      </span>
    </div>;
  };
};

let () = {
  let server = Httpd.create();
  let addr = Httpd.addr(server);
  let port = Httpd.port(server);
  Httpd.add_route_handler(
    ~meth=`GET,
    server,
    Httpd.Route.(exact("header") @/ string @/ return),
    (_name, _req) => {
      let html =
        ReactDOM.renderToString(
          <Page scripts=["/static/header.js"]>
            <Shared_native.Ahrefs />
          </Page>,
        );
      Httpd.Response.make_string(Ok(html));
    },
  );
  Httpd.add_route_handler(
    ~meth=`GET,
    server,
    Httpd.Route.(exact("markup") @/ string @/ return),
    (_name, _req) => {
      let html =
        ReactDOM.renderToStaticMarkup(
          <Page scripts=["/static/app.js"]> <Shared_native.App /> </Page>,
        );
      Httpd.Response.make_string(Ok(html));
    },
  );
  Httpd.add_route_handler(
    ~meth=`GET,
    server,
    Httpd.Route.(exact("string") @/ return),
    _req => {
      let html =
        ReactDOM.renderToString(
          <Page scripts=["/static/app.js"]> <Shared_native.App /> </Page>,
        );
      Httpd.Response.make_string(Ok(html));
    },
  );
  /*
   TODO: Render to stream
    Dream.get("/stream", _request =>
           Dream.stream(
             ~headers=[("Content-Type", "text/html")],
             response_stream => {
               let (stream, _) =
                 ReactDOM.renderToLwtStream(<Page> <Comments.App /> </Page>);

               Lwt_stream.iter_s(
                 data => {
                   let%lwt () = Dream.write(response_stream, data);
                   Dream.flush(response_stream);
                 },
                 stream,
               );
             },
           )
         ),

   Httpd.add_route_handler_stream(
        ~meth=`GET,
        server,
        Httpd.Route.(exact("stream") @/ return),
        req => {
          let (_stream, _close) =
            ReactDOM.renderToLwtStream(
              <Page scripts=["/static/app.js"]> <Shared_native.App /> </Page>,
            );
          Lwt_stream.iter_s(
               data => {
                 let%lwt () = Dream.write(response_stream, data);
                 Dream.flush(response_stream);
               },
               stream,
             );
          Tiny_httpd_stream.iter(write, req.Request.body);
          let a = Httpd.Byte_stream.of_string("asdf");
          Httpd.Response.make_stream(Ok(a));
        },
      ); */

  let virtual_fs = Httpd_dir.vfs_of_dir("static");

  let _ =
    Httpd_dir.add_vfs(
      server,
      ~prefix="static",
      ~vfs=virtual_fs,
      ~config=
        Httpd_dir.config(
          ~download=true,
          ~upload=false,
          ~dir_behavior=Httpd_dir.Index,
          (),
        ),
    );

  Httpd.set_top_handler(
    server,
    req => {
      let html =
        ReactDOM.renderToString(<Page> <Not_found path={req.path} /> </Page>);
      Httpd.Response.make_string(Ok(html));
    },
  );

  Httpd.add_route_handler(
    server,
    Httpd.Route.(return),
    _req => {
      let html =
        ReactDOM.renderToString(
          <Page scripts=["/static/header.js"]> <Home /> </Page>,
        );
      Httpd.Response.make_string(Ok(html));
    },
  );

  switch (
    Httpd.run(server, ~after_init=() =>
      Printf.printf("Listening on http://%s:%d\n%!", addr, port)
    )
  ) {
  | Ok () => ()
  | Error(e) => raise(e)
  };
};
