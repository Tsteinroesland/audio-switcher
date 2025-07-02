#!/usr/bin/env bb
(require '[clojure.java.shell :refer [sh]])
(require '[clojure.string :refer [includes? split-lines]])

(def status-lines
  "Call the shell once and store the output lines"
  (->> (sh "wpctl" "status")
       (:out)
       (split-lines)))

(def current-device
  "Find the current device using the stored lines"
  (->> status-lines
       (drop-while #(not (includes? % "Sinks:")))
       (drop-while #(not (includes? % "*")))
       (first)))

(def output-device
  "Determine the target device"
  (if (includes? current-device "Built-in Audio Analog Stereo")
    "SteelSeries Arctis 7 Game"
    "Built-in Audio Analog Stereo"))

(def sink-id
  "Find the sink ID, also using the same stored lines"
  (->> status-lines
       (drop-while #(not (includes? % "Sinks:")))
       (drop-while #(not (includes? % output-device)))
       (first)
       (re-find #"\d+")))

;; Execute the final command only if a valid ID was found
(when sink-id
  (sh "wpctl" "set-default" sink-id))
