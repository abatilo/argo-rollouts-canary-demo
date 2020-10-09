package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	h := http.NewServeMux()
	h.HandleFunc("/ping", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "pong")
	})

	s := &http.Server{
		Addr:    ":8080",
		Handler: h,
	}

	log.Println("Listening...")
	s.ListenAndServe()
}
