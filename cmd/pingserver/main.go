package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
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

	c := make(chan os.Signal, 1)
	done := make(chan struct{})
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-c
		log.Println("Shutting down")
		time.Sleep(30 * time.Second)
		s.Shutdown(context.Background())
		close(done)
	}()

	log.Println("Listening...")
	s.ListenAndServe()
	<-done
}
