(ns core
  (:require basic-math))

(defn -main [& args]
  (println "Args sum: " (reduce basic-math/sum (map #(Integer/parseInt %) args))))
