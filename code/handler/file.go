package handler

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"os"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gofiber/fiber/v2"
)

var (
	S3_BUCKET = os.Getenv("S3_BUCKET")
)

func GetFile(s3client *s3.Client) fiber.Handler {
	return func(c *fiber.Ctx) error {
		filename, _ := url.QueryUnescape(c.Params("name"))

		result, err := s3client.GetObject(context.TODO(), &s3.GetObjectInput{
			Bucket: &S3_BUCKET,
			Key:    &filename,
		})
		if err != nil {
			log.Println(err)
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": fmt.Sprintf("Couldn't get object %v %v", S3_BUCKET, filename),
			})
		}

		defer result.Body.Close()
		file, _ := os.CreateTemp("", filename)

		defer file.Close()

		return c.Download(file.Name(), filename)
	}
}

func UploadFile(s3client *s3.Client) fiber.Handler {
	return func(c *fiber.Ctx) error {
		file, err := c.FormFile("file")
		if err != nil {
			log.Println(err)
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Failed to process file",
			})
		}

		// Handle processing of the uploaded file
		filename := file.Filename
		content, _ := file.Open()

		_, err = s3client.PutObject(context.TODO(), &s3.PutObjectInput{
			Bucket: &S3_BUCKET,
			Key:    &filename,
			Body:   content,
		})
		if err != nil {
			log.Println(err)
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Failed to save file",
			})
		}

		return c.JSON(fiber.Map{
			"message": fmt.Sprintf("File uploaded successfully! The file name is: %v", filename),
		})
	}
}

func DeleteFile(s3client *s3.Client) fiber.Handler {
	return func(c *fiber.Ctx) error {
		filename, _ := url.QueryUnescape(c.Params("name"))

		_, err := s3client.DeleteObject(context.TODO(), &s3.DeleteObjectInput{
			Bucket: &S3_BUCKET,
			Key:    &filename,
		})
		if err != nil {
			log.Println(err)
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": fmt.Sprintf("Couldn't delete file %v", filename),
			})
		}

		return c.JSON(fiber.Map{
			"message": "File deleted successfully!",
		})
	}
}
