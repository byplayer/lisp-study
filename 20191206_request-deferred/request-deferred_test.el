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
(message "data: %s" (alist-get 'items result_data))
(message "data: %s" (car (append (alist-get 'items result_data) nil)))
(message "data: %s" (alist-get 'id (car (append (alist-get 'items result_data) nil))))
(message "due: %s" (alist-get 'due (car (append (alist-get 'items result_data) nil))))

(let
    ((items '())
     (due nil))
  (with-temp-file org-todoist-agenda-file
    (cl-loop for item in (append (alist-get 'items result_data) nil) do
             (message "data: %s" (alist-get 'id (car (append (alist-get 'items result_data) nil))))
             (message "%s" (alist-get 'content item))
             (insert (format ort-todoist-title-format (alist-get 'content item)))
             (newline)

             (setq due (alist-get 'due item))
             (if (and due (alist-get 'date due))
                 (progn
                   (insert (format "SCHEDULED: %s" (alist-get 'date due)))
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
