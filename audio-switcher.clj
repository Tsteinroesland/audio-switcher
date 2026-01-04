#!/usr/bin/env bb
(require '[clojure.java.shell :refer [sh]])
(require '[clojure.string :refer [includes? split-lines split trim]])

(def devices
  #{"SteelSeries Arctis 7 Game"
    "Built-in Audio Analog Stereo"
    "Torstein's Pixel Buds Pro"})

(def status-lines
  "Call the shell once and store the output lines"
  (->> (sh "wpctl" "status")
       (:out)
       (split-lines)))

(def available-sinks
  (->> status-lines
       (drop-while #(not (includes? % "Sinks")))
       (drop 1)
       (take-while #(re-find #"[0-9]+\." %))
       (map (fn [dev] (->> dev
                           (#(split % #"  "))
                           (filter #(re-find #"[0-9]+\." %))
                           (first)
                           (trim)
                           (#(split % #"\.")))))
       (map second)
       (map trim)))

(def current-device
  "Find the current device using the stored lines"
  (->> status-lines
       (drop-while #(not (includes? % "Sinks:")))
       (drop-while #(not (includes? % "*")))
       (first)
       (#(split % #"  "))
       (filter #(re-find #"[0-9]+\." %))
       (first)
       (trim)
       (#(split % #"\."))
       (second)
       (trim)))

(def output-device
  "Determine the target device"
  (case current-device
    "Built-in Audio Analog Stereo"
    "SteelSeries Arctis 7 Game"

    "SteelSeries Arctis 7 Game"
    (if (some #(includes? % "Torstein's Pixel Buds Pro") available-sinks)
      "Torstein's Pixel Buds Pro"
      "Built-in Audio Analog Stereo")

    "Torstein's Pixel Buds Pro"
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
