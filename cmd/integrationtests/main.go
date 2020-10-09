package main

import (
	"flag"
	"log"
	"os"
	"time"
)

func main() {
	succeeded := flag.Bool("succeed", true, "Whether or not to have this test succeed (default: true)")
	flag.Parse()

	log.Println("Performing integration tests")
	time.Sleep(2 * time.Second)

	if !*succeeded {
		log.Println("Integration tests failed")
		os.Exit(1)
	}
	log.Println("Integration tests succeeded")
}
