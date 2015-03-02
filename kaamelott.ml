open Lwt
open Printf
open V1_LWT

module Main (C:CONSOLE) (FS:KV_RO) (S:Cohttp_lwt.Server) = struct

  let start c fs http =

    let read_fs name =
      FS.size fs name
      >>= function
      | `Error (FS.Unknown_key _) -> fail (Failure ("read " ^ name))
      | `Ok size ->
        FS.read fs name 0 (Int64.to_int size)
        >>= function
        | `Error (FS.Unknown_key _) -> fail (Failure ("read " ^ name))
        | `Ok bufs -> return (Cstruct.copyv bufs)
    in

    let json =
      read_fs "/kaamelott"
      >>= fun file ->
      let cut = Re_str.split (Re_str.regexp "%") file in
      let splitted = List.map (fun a ->  Re_str.split (Re_str.regexp "\n") a) cut in
      return @@ List.map (fun a ->
          let l = List.rev a in
          let meta = List.hd l in
          let meta_line =  Re_str.string_after (Re_str.string_before meta (String.length meta - 1)) 1 in
          let quote = List.fold_right (fun acc elm -> acc ^ elm ^ "\\n")
          (List.rev @@ List.tl l) "" in
          "{\"quote\": \"" ^ quote ^ "\""
          ^ ", \"meta\": \"" ^  meta_line  ^ "\"}"
          ) (List.tl @@ List.rev splitted)
    in

    let get_random_quote _ =
      Random.self_init();
      json >>= fun quotes ->
      return @@ List.nth quotes (Random.int (List.length quotes)) in

    let rec dispatcher _ =
      let h = Cohttp.Header.add_opt None "content-type" "application/json" in
      let headers = Cohttp.Header.add h "Access-Control-Allow-Origin" "*" in
      get_random_quote ()
      >>= fun body ->
        S.respond_string ~status:`OK ~body ~headers ()
      in

    let callback conn_id request body =
      let uri = S.Request.uri request in
      dispatcher ()
    in
    let conn_closed (_,conn_id) =
      let cid = Cohttp.Connection.to_string conn_id in
      C.log c (Printf.sprintf "conn %s closed" cid)
    in
    http (S.make ~conn_closed ~callback ())

end
