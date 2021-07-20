open Lwt
open Cohttp_lwt_unix
open Core

let body =
  Client.get (Uri.of_string "https://raw.hellogithub.com/hosts")
  >>= fun (_, body) -> Cohttp_lwt.Body.to_string body

let rec any f list =
  match list with
  | [] -> true
  | head :: tail -> if f head then any f tail else false

let check_host_line line =
  if String.length line = 0 then true
  else
    let r = Str.regexp "^[#1-9\n\\s\r]" in
    let b = Str.string_match r line 0 in
    b

let is_host body =
  let lines = String.split body ~on:'\n' in
  if any check_host_line lines then true else false

let write_host ~path body_string =
  try
    let file = Out_channel.create path in
    Printf.fprintf file "%s" body_string;
    Out_channel.flush file;
    Out_channel.close file
  with Sys_error _ -> Printf.eprintf "can not write to file %s\n" path

let () =
  let usage_msg = "Sync hosts content from github \n [-path] <path> " in
  let path = ref "/etc/hosts" in
  let anon_fun s = ignore s in
  let speclist = [ ("-path", Arg.Set_string path, "Set output file name") ] in
  Arg.parse speclist anon_fun usage_msg;
  while true do
    let body_string = Lwt_main.run body in
    if is_host body_string then write_host ~path:!path body_string
    else Printf.fprintf stderr "http response body is not hosts contents\n";
    (*sleep for a second*)
    Out_channel.flush stdout;
    Out_channel.flush stderr;
    Unix.sleep (60 * 10)
  done
