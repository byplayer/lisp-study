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


(message "data: %s" result_data)
(message "data: %s" (car (append (alist-get 'projects result_data) nil)))
(message "data: %s" (alist-get 'id (car (append (alist-get 'projects result_data) nil))))

(setq projects '())
(message "%s" projects)
(cl-loop for project in (append (alist-get 'projects result_data) nil) do
         (message "%s" (alist-get 'id project))
         (append projects '((alist-get 'id project) project))
         )

(cl-loop for elem in result_data do (message "%s" (plist-get result_data "tooltips")))
