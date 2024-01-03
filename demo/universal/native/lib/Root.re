[@react.component]
let make = (~children, ~background) => {
  <div
    className={Cx.make([
      "margin-0",
      "padding-0",
      "w-[100vw]",
      "h-[100vh]",
      "flex",
      "flex-col",
      "items-center",
      "justify-start",
      Theme.background(background),
    ])}>
    children
  </div>;
};
