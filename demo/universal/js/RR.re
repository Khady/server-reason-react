[@mel.module "react"]
external useStateUncurry:
  ([@mel.uncurry] (unit => 'state)) =>
  ('state, (. ('state => 'state)) => unit) =
  "useState";

let useState = initialState => {
  let (state, setState) = useStateUncurry(initialState);
  let setState = React.useCallback1(fn => setState(. fn), [|setState|]);
  (state, setState);
};

let useStateValue = initialState => {
  let (state, setState) = useStateUncurry(_ => initialState);
  let setValueStatic = newState => setState(. _ => newState);
  (state, setValueStatic);
};
