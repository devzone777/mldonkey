type date_format =
  Second
| Minute
| Hour
| Day
| WeekDay
| Month
| MonthNumber
| Year
| Comma
| Space
| Colon
| Dot
| Minus
| Zone

let months = [| "Jan"; "Feb"; "Mar"; "Apr"; "May"; "Jun";
                "Jul"; "Aug"; "Sep"; "Oct"; "Nov"; "Dec"|]

let days = [| "Sun"; "Mon"; "Tue"; "Wed"; "Thu"; "Fri"; "Sat" |]

let month = ref (fun n -> months.(n))
let day = ref (fun n -> days.(n))
  
let string_of_date formats tm date =
  List.fold_left (fun s format ->
      match format with
        Second -> Printf.sprintf "%s%02d" s tm.Unix.tm_sec
      | Minute -> Printf.sprintf "%s%02d" s tm.Unix.tm_min
      | Hour -> Printf.sprintf "%s%02d" s tm.Unix.tm_hour
      | Day -> Printf.sprintf "%s%02d" s tm.Unix.tm_mday
      | WeekDay  -> Printf.sprintf "%s%s" s (!day tm.Unix.tm_wday)
      | Month -> Printf.sprintf "%s%s" s (!month tm.Unix.tm_mon)
      | MonthNumber -> Printf.sprintf "%s%02d" s (tm.Unix.tm_mon+1)
      | Year -> Printf.sprintf "%s%04d" s (1900+tm.Unix.tm_year)
      | Comma -> s ^ ","
      | Space -> s ^ " "
      | Colon -> s ^ ":"
      | Dot -> s ^ "."
      | Minus -> s ^ "-"
      | Zone -> Printf.sprintf "%s%s" s (Rss_date.mk_timezone date)
  ) "" formats

  
let to_string date =
  string_of_date [Hour;Colon;Minute;Space; Space; WeekDay; Space; Day; Space;Month;]
    (Unix.localtime date) date
    
let to_full_string date =
  string_of_date [Hour;Colon;Minute;Space; Space; WeekDay; Space; Day; Space;Month; Space;Year]
    (Unix.localtime date) date

let simple date = 
  string_of_date [Hour;Colon;Minute;Colon;Second;Space; Space; WeekDay]
    (Unix.localtime date) date

let reverse date = 
  string_of_date [Year;MonthNumber;Day;Minus;Hour;Minute;Second]
    (Unix.localtime date) date
  
let mail_string date =
    string_of_date [WeekDay;Comma;Space;Day;Space;Month;Space;Year;Space;Hour;Colon;Minute;Colon;Second;Space;Zone]
      (Unix.localtime date) date

let hour_in_secs = 3600
let day_in_secs = 24 * hour_in_secs
let year_in_secs = 365 * day_in_secs

let time_to_string time print_format =
  let days = time / 60 / 60 / 24 in
  let rest = time - days * 60 * 60 * 24 in
  let hours = rest / 60 / 60 in
  let rest = rest - hours * 60 * 60 in
  let minutes = rest / 60 in
  let seconds = rest - minutes * 60 in
  match print_format with
    "long" ->

  if days > 0
    then Printf.sprintf " %dd " days
  else if hours > 0
    then Printf.sprintf " %d:%02d:%02d " hours minutes seconds
    else Printf.sprintf " %d:%02d " minutes seconds

  | "verbose" ->
	Printf.sprintf "%s%s%dm %ds"
	  (if days > 0 then (string_of_int days) ^ "d " else "")
	  (if hours > 0 then (string_of_int hours) ^ "h " else "")
	  minutes seconds
  | _ -> ""
