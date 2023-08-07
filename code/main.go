package main

import (
	"context"
	"interview/handler"
	"log"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main() {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Println("Couldn't load default configuration. Have you set up your AWS account?")
		log.Println(err)
		return
	}

	s3client := s3.NewFromConfig(cfg)

	// Server
	app := fiber.New()
	app.Use(logger.New())

	app.Get("/healthz", func(c *fiber.Ctx) error {
		return c.Status(200).JSON(fiber.Map{"message": "OK"})
	})

	v1 := app.Group("/v1")
	v1.Get("/files/:name", handler.GetFile(s3client))
	v1.Post("/files/upload", handler.UploadFile(s3client))
	v1.Delete("/files/:name", handler.DeleteFile(s3client))

	app.Listen(":3000")
}
