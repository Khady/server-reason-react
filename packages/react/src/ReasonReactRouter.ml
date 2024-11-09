module Router = struct
  module URL = struct
    type url = { path : string list; hash : string; search : string }

    let url : url option ref = ref None
    let set ({ path; search; hash } : url) = url := Some { path; search; hash }
    let get () = !url
  end
end

let push (_path : string) = ()
let replace (_path : string) = ()

type url = Router.URL.url
type watcherID = unit -> unit

let url ?serverUrlString () =
  match serverUrlString with
  | Some serverUrlString -> (
      match URL.make serverUrlString with
      | Some url ->
          let path =
            URL.pathname url |> String.split_on_char '/'
            |> List.filter (fun s -> s <> "")
          in
          let hash = URL.hash url |> Option.value ~default:"" in
          let search = URL.search url |> Option.value ~default:"" in
          let url : url = { path; hash; search } in
          url
      | None -> raise (Failure "Invalid server URL"))
  | None -> (
      match Router.URL.get () with
      | Some url -> url
      | None -> raise (Failure "Native URL not set"))

let dangerouslyGetInitialUrl = url
let watchUrl _callback () = ()
let unwatchUrl _watcherID = ()

let useUrl ?(serverUrl : url option) () =
  match serverUrl with Some serverUrl -> serverUrl | None -> url ()
