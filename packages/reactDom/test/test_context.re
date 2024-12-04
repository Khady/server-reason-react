let assert_string = (left, right) =>
  Alcotest.check(Alcotest.string, "should be equal", right, left);

let context = React.createContext(10);

module ContextProvider = {
  include React.Context;

  let make = React.Context.provider(context);
};

module ContextConsumer = {
  [@react.component]
  let make = () => {
    let value = React.useContext(context);
    <section> {React.int(value)} </section>;
  };
};

let context = () => {
  let component =
    <ContextProvider value=20> <ContextConsumer /> </ContextProvider>;

  assert_string(
    ReactDOM.renderToStaticMarkup(component),
    "<section>20</section>",
  );
};

let test = (title, fn) => (
  Printf.sprintf("React.Context / %s", title),
  [Alcotest_lwt.test_case_sync("", `Quick, fn)],
);

let tests = [test("Get context value with provider value", context)];
