;; Required libraries
(require 'json)
(require 'request)
(require 'timer)

;; Functional variables
(defvar stock_symbol_num 0)
(defvar stock-change-time 60)
(defvar stock_tracker_symbols ())
(defvar stock-tracker-timer nil)
(defvar stock-tracker-api-key nil)


(defun start-stock-tracker ()
  "Start the stock tracker program"
  (interactive) ;; make accessible while in editor modes
  (start-stock-timer)
  )

(defun stop-stock-tracker ()
  "Start the stock tracker program"
  (interactive) ;; make accessible while in editor modes
  (kill-stock-timer)
  )

(defun get-stock-price (stock_symbol)
  "Retrieve current stock price for stock symbol specified"
  (request
   (format "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=%S&interval=1min&apikey=%S" stock_symbol stock-tracker-api-key)
   ;; "http://httpbin.org/ip"
   :parser 'json-read
   :success (cl-function
	     (lambda (&key data &allow-other-keys)
	       (when data
		 (setq header-line-format (format "%s: $%s" header-line-format (cdr (car (cdr (car (cdr (car (cdr data))))))))))))))

(defun print-stock-to-header (stock_symbol)
  "Prints the current price of a stock symbol to the header bar"
  (progn
    (setq header-line-format stock_symbol)
    (get-stock-price stock_symbol)))

(defun show-fit-stock-price ()
  "Shows the fitbit stock price."
  (interactive)
  (print-stock-to-header 'FIT))

(defun start-stock-timer ()
  "Starts the stock timer"
  (progn
    (setq stock-tracker-timer (run-at-time "1 sec" stock-change-time 'stock-tracker-timer-handler))
    (message "Stock timer started.")
    ))

(defun kill-stock-timer ()
  "Kill the stock timer"
  (cancel-timer stock-tracker-timer)
  )

;; Assumes stock_symbol_num is already initialized
(defun stock-tracker-timer-handler ()
  "Timer 'interrupt' function"
  (print-stock-to-header
   (nth
    (if ( > stock_symbol_num ( - (length stock_tracker_symbols) 1))
	(setq stock_symbol_num 0)
      (setq stock_symbol_num (+ stock_symbol_num 1))) stock_tracker_symbols))
   )

;;;###autoload
(defgroup stock-tracker nil
  "Stock tracker."
  :group 'applications
  :prefix "stock-tracker-")

(provide 'stock-tracker)