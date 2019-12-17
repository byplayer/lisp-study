(require 'request-deferred)

;; ref
;; https://github.com/tkf/emacs-request

(request
 "http://httpbin.org/get"
 :params '(("key" . "value") ("key2" . "value2"))
 :headers '(("hoge" . "fuga"))
 :parser 'json-read
 :success (cl-function
           (lambda (&key data &allow-other-keys)
             (message "I sent: %S" (assoc-default 'args data)))))

(request
 "http://httpbin.org/get"
 :params '(("key" . "value") ("key2" . "value2"))
 :headers '(("hoge" . "fuga"))
 :parser 'json-read
 :success (cl-function
           (lambda (&key data &allow-other-keys)
             (message "I sent: %S" data))))

(let ((token (plist-get org-todoist-token-plist :access_token)))
  (message "%s" token)
  (request
    "https://api.todoist.com/sync/v8/sync"
    :type "POST"
    :data `(("token" . ,token)
            ("sync_token" . "*") ("resource_types" . "[\"all\"]"))
    :parser 'json-read
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (setq result_data data)
                (message "I sent: %S" result_data))))
  )

;; projects
(message "data: %s" result_data)
(message "data: %s" (car (append (alist-get 'projects result_data) nil)))
(message "data: %s" (alist-get 'id (car (append (alist-get 'projects result_data) nil))))

(parse-time-string "2019-12-01")
; Parse the time-string STRING into (SEC MIN HOUR DAY MON YEAR DOW DST TZ)
(parse-time-string "2019-12-01 18:30 +0800")
(parse-time-string "2019-12-01")
(length "2019-12-01")
(timezone-parse-date "2019-12-01T18:30Z+0800")
(timezone-parse-date "2019-12-01T18:30Z")
(timezone-parse-date "2019-12-20T15:00:00")
(timezone-parse-time "15:00:00")
(timezone-parse-date "2019-12-25T12:00:00Z")
(timezone-parse-date "2019-12-25")
(timezone-fix-time "2019-12-25T12:00:00Z" nil "+0800")
(timezone-fix-time "2019-12-25T12:00:00" nil "+0800")
(timezone-fix-time "2019-12-25" nil "+0800")
(timezone-zone-to-minute "+08:00")

(timezone-zone-to-minute (s-replace ":" "" "+08:00"))

(let
    ((projects '()))
  (cl-loop for project in (append (alist-get 'projects result_data) nil) do
           ; (message "%s" (alist-get 'id project))
           (add-to-list 'projects `(,(alist-get 'id project) ,project))
           )
  (message "%s" projects)
  ; (message "%s" (alist-get '2209159964 projects))
  )

;; items
(message "user: %s" (alist-get 'user result_data))
(message "user.tz_info: %s" (alist-get 'tz_info (alist-get 'user result_data)))
(message "user.tz_info.gmt_string: %s"
         (alist-get 'gmt_string (alist-get 'tz_info (alist-get 'user result_data))))
(message "data: %s" (alist-get 'items result_data))
(message "data: %s" (car (append (alist-get 'items result_data) nil)))
(message "data: %s" (alist-get 'id (car (append (alist-get 'items result_data) nil))))
(message "due: %s" (alist-get 'due (car (append (alist-get 'items result_data) nil))))

(org-todoist-dig result_data '(user tz_info gmt_string))

(listp 'abc)
(listp '('abc 'zza 'zzzb))
(car '('abc 'zza 'zzzb))
(cdr '('zzzb))
(length '('abc 'zza 'zzzb))
(format "<%04d-%02d-%02d %02d:%02d>"
              '(2010 1 30 22 15))
(defun org-todoist-make-org-due (tz-data)
  "Convert timezone data to org due date format string.
Expected org date format as <%Y-%m-%d %a HH:mm>
TZ-DATA is list of (year month day time_str).
The time_str is expected HH:MM:SS"
  (let ((tz-time))
    (if (nth 3 tz-data)
        (progn
          (setq tz-time (append (timezone-parse-time (nth 3 tz-data)) nil))
          (format "<%04d-%02d-%02d %02d:%02d>"
                  (string-to-number (nth 0 tz-data))
                  (string-to-number (nth 1 tz-data))
                  (string-to-number (nth 2 tz-data))
                  (string-to-number (nth 0 tz-time))
                  (string-to-number (nth 1 tz-time))))
      (format "<%04d-%02d-%02d>"
              (string-to-number (nth 0 tz-data))
              (string-to-number (nth 1 tz-data))
              (string-to-number (nth 2 tz-data))))))

(org-todoist-make-org-due '(2019 12 3))
(org-todoist-make-org-due '(2019 12 3 "09:04"))

(string-to-number "100")

(defun org-todoist-convert-due-date-to-user-tz (due local-tz)
  "Convert todoist due time to user timezone time.
DUE is the value of due date.
LOCAL-TZ is user local timezone(+0800 etc)."
  (let ((due-date))
    (if due
        (if (= 10 (length due))
            due
          (progn
            (setq due-date (append (timezone-parse-date due) nil))
            (if (nth 4 due-date)
                (progn
                  (setq due-date
                        (append (timezone-fix-time due nil local-tz) nil))
                  (format "<%04d-%02d-%02d %02d:%02d>"
                          (nth 0 due-date)
                          (nth 1 due-date)
                          (nth 2 due-date)
                          (nth 3 due-date)
                          (nth 4 due-date))
                  )
              (progn
                (org-todoist-make-org-due due-date)
                )
              )
            )
          )
      nil)
    ))
(org-todoist-convert-due-date-to-user-tz "2019-12-25T12:01:00Z" "+0800")
(org-todoist-convert-due-date-to-user-tz "2019-12-25T12:00:00" "+0800")
(org-todoist-convert-due-date-to-user-tz "2019-12-25" "+0800")
(org-todoist-convert-due-date-to-user-tz nil "+0800")


(let
    ((items '())
     (due nil)
     (local-tz (org-todoist-dig result_data '(user tz_info gmt_string))))
  (unless local-tz
    (setq local-tz "+0000"))
  (message "local-tz:%s" local-tz)
  (with-temp-file org-todoist-agenda-file
    (cl-loop for item in (append (alist-get 'items result_data) nil) do
             (insert (format org-todoist-title-format (alist-get 'content item)))
             (newline)
             (setq due (alist-get 'due item))
             (if (and due (alist-get 'date due))
                 (progn
                   (insert (format "SCHEDULED: %s"
                                   (org-todoist-convert-due-date-to-user-tz
                                    (alist-get 'date due)
                                    local-tz)))
                   (newline)))
             (insert ":PROPERTIES:")
             (newline)
             (insert (format ":%s: %s" org-tooist-item-id-property (alist-get 'id item)))
             (newline)
             (insert ":END:")
             (newline)
             (insert ":org-todoist:")
             (newline)
             (insert ":END:")
             (newline)
             )
  ))
(message "data: %s" (car (append (alist-get 'items result_data) nil)))

(message "%s" (nth 3 '(zero one two three)))

(setq org-todoist-agenda-file (expand-file-name "todoist.org" my-org-agenda-directory))
(find-file org-todoist-agenda-file)
(with-temp-file org-todoist-agenda-file
  (goto-char 1)
  (insert "Hey"))


"* contents
SCHEDULED: <2019-12-15 Sun 10:00-10:15>
:PROPERTIES:
:item-id: 1234
:Effort:   01:00
:END:
:org-todoist:
:END:

Hey
"
